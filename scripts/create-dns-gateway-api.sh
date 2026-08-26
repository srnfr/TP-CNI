#!/usr/bin/env bash

set -Eeuo pipefail

umask 077

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)

if [[ -f "${REPO_DIR}/.env" ]]; then
    set -a
    source "${REPO_DIR}/.env"
    set +a
fi

DNS_DOMAIN=${DNS_DOMAIN:-randco.eu}
DNS_TTL=${DNS_TTL:-60}
DNS_CONTEXT=${DNS_CONTEXT:-${CTX:-}}
K8S_CONTEXT=${K8S_CONTEXT:-${CTX_K8S:-}}
GATEWAY_NAMESPACE=${GATEWAY_NAMESPACE:-default}
GATEWAY_NAME=${GATEWAY_NAME:-demo-gateway}
CLUSTER_NAME_REGEX=${CLUSTER_NAME_REGEX:-grp[0-9]+}
DRY_RUN=false

usage() {
    printf 'Usage: %s [--dry-run]\n' "${0##*/}"
    printf '\n'
    printf 'Remplace les enregistrements A grpX.%s à partir des\n' "${DNS_DOMAIN}"
    printf 'Gateway API et des Load Balancers DigitalOcean associés.\n'
    printf '\n'
    printf 'Variables facultatives :\n'
    printf '  DNS_DOMAIN             Zone DNS (défaut : randco.eu)\n'
    printf '  DNS_TTL                TTL des enregistrements (défaut : 60)\n'
    printf '  DNS_CONTEXT            Contexte doctl qui héberge la zone DNS (courant par défaut)\n'
    printf '  K8S_CONTEXT            Contexte doctl qui héberge DOKS et les LB (courant par défaut)\n'
    printf '  GATEWAY_NAMESPACE      Namespace de la Gateway (défaut : default)\n'
    printf '  GATEWAY_NAME           Nom de la Gateway (défaut : demo-gateway)\n'
    printf '  CLUSTER_NAME_REGEX     Filtre des clusters (défaut : grp[0-9]+)\n'
    printf '\n'
    printf 'CTX et CTX_K8S restent acceptées pour compatibilité avec le fichier .env.\n'
}

for argument in "$@"; do
    case "${argument}" in
        --dry-run)
            DRY_RUN=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'Argument inconnu : %s\n\n' "${argument}" >&2
            usage >&2
            exit 2
            ;;
    esac
done

for command_name in doctl kubectl jq mktemp; do
    if ! command -v "${command_name}" >/dev/null 2>&1; then
        printf 'Commande requise absente : %s\n' "${command_name}" >&2
        exit 1
    fi
done

if [[ ! "${DNS_TTL}" =~ ^[0-9]+$ ]] || ((10#${DNS_TTL} == 0)); then
    printf 'DNS_TTL doit être un entier positif.\n' >&2
    exit 1
fi

is_ipv4() {
    local address=$1
    local octet
    local -a octets

    [[ "${address}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
    IFS=. read -r -a octets <<< "${address}"
    for octet in "${octets[@]}"; do
        ((10#${octet} <= 255)) || return 1
    done
}

doctl_dns() {
    if [[ -n "${DNS_CONTEXT}" ]]; then
        doctl "$@" --context "${DNS_CONTEXT}"
    else
        doctl "$@"
    fi
}

doctl_k8s() {
    if [[ -n "${K8S_CONTEXT}" ]]; then
        doctl "$@" --context "${K8S_CONTEXT}"
    else
        doctl "$@"
    fi
}

replace_record() {
    local hostname=$1
    local address=$2
    local short_name=${hostname%.${DNS_DOMAIN}}
    local records_json matching_records existing_records
    local existing_count incorrect_count record_id record_data

    records_json=$(doctl_dns compute domain records list "${DNS_DOMAIN}" --output json)
    matching_records=$(jq --arg fqdn "${hostname}" --arg short "${short_name}" \
        '[.[] | select(.type == "A" and (.name == $fqdn or .name == $short))]' \
        <<< "${records_json}")
    existing_count=$(jq 'length' <<< "${matching_records}")
    incorrect_count=$(jq --arg address "${address}" \
        '[.[] | select(.data != $address)] | length' \
        <<< "${matching_records}")

    if ((existing_count > 0 && incorrect_count == 0)); then
        printf 'CONSERVATION %-25s = %s (déjà correct)\n' \
            "${hostname}" "${address}"
        return 0
    fi

    existing_records=$(jq -r --arg fqdn "${hostname}" --arg short "${short_name}" \
        '.[] | select(.type == "A" and (.name == $fqdn or .name == $short)) | [.id, .data] | @tsv' \
        <<< "${records_json}")

    while IFS=$'\t' read -r record_id record_data; do
        [[ -n "${record_id}" ]] || continue
        if [[ "${DRY_RUN}" == true ]]; then
            printf 'SUPPRESSION %-25s %s (ID %s, simulation)\n' \
                "${hostname}" "${record_data}" "${record_id}"
        else
            doctl_dns compute domain records delete "${DNS_DOMAIN}" \
                "${record_id}" --force >/dev/null
            printf 'SUPPRESSION %-25s %s (ID %s)\n' \
                "${hostname}" "${record_data}" "${record_id}"
        fi
    done <<< "${existing_records}"

    if [[ "${DRY_RUN}" == true ]]; then
        printf 'CRÉATION    %-25s -> %s (simulation)\n' "${hostname}" "${address}"
    else
        doctl_dns compute domain records create "${DNS_DOMAIN}" \
            --record-type A \
            --record-name "${hostname}" \
            --record-data "${address}" \
            --record-ttl "${DNS_TTL}" >/dev/null
        printf 'CRÉATION    %-25s -> %s\n' "${hostname}" "${address}"
    fi
}

temporary_directory=$(mktemp -d)
kubeconfig_file="${temporary_directory}/kubeconfig"
trap 'rm -rf "${temporary_directory}"' EXIT

printf 'Zone DNS       : %s\n' "${DNS_DOMAIN}"
printf 'Contexte DNS   : %s\n' "${DNS_CONTEXT:-courant doctl}"
printf 'Contexte DOKS  : %s\n' "${K8S_CONTEXT:-courant doctl}"
printf 'Gateway        : %s/%s\n' "${GATEWAY_NAMESPACE}" "${GATEWAY_NAME}"
printf 'Mode           : %s\n\n' "$([[ "${DRY_RUN}" == true ]] && printf simulation || printf application)"

clusters=$(doctl_k8s kubernetes cluster list --format Name --no-header)

processed=0
errors=0

while IFS= read -r cluster_name; do
    [[ -n "${cluster_name}" ]] || continue
    [[ "${cluster_name}" =~ ${CLUSTER_NAME_REGEX} ]] || continue

    printf 'Cluster        : %s\n' "${cluster_name}"

    if ! doctl_k8s kubernetes cluster kubeconfig show "${cluster_name}" \
        --expiry-seconds 600 > "${kubeconfig_file}"; then
        printf 'ERREUR         : kubeconfig inaccessible\n\n' >&2
        ((errors += 1))
        continue
    fi

    if ! gateway_json=$(kubectl --kubeconfig "${kubeconfig_file}" \
        --namespace "${GATEWAY_NAMESPACE}" get gateway "${GATEWAY_NAME}" \
        --output json 2>/dev/null); then
        printf 'IGNORÉ         : Gateway absente\n\n'
        continue
    fi

    hostname=$(jq -r --arg domain ".${DNS_DOMAIN}" \
        '[.spec.listeners[]?.hostname | select(type == "string" and endswith($domain))][0] // empty' \
        <<< "${gateway_json}")
    gateway_ip=$(jq -r \
        '[.status.addresses[]?.value | select(type == "string")][0] // empty' \
        <<< "${gateway_json}")
    load_balancer_name=$(jq -r \
        '.metadata.annotations["service.beta.kubernetes.io/do-loadbalancer-name"] // empty' \
        <<< "${gateway_json}")

    if [[ ! "${hostname}" =~ ^grp[0-9]+\.${DNS_DOMAIN//./\.}$ ]]; then
        printf 'ERREUR         : hostname grpX.%s introuvable dans la Gateway\n\n' "${DNS_DOMAIN}" >&2
        ((errors += 1))
        continue
    fi

    if ! is_ipv4 "${gateway_ip}"; then
        printf 'ERREUR         : aucune IPv4 publique dans le statut de la Gateway\n\n' \
            >&2
        ((errors += 1))
        continue
    fi

    if [[ -n "${load_balancer_name}" ]]; then
        printf 'Load Balancer  : %s (adresse publiée par la Gateway)\n' \
            "${load_balancer_name}"
    else
        printf 'Load Balancer  : annotation absente (adresse publiée par la Gateway)\n'
    fi

    printf 'Adresse        : %s\n' "${gateway_ip}"

    if replace_record "${hostname}" "${gateway_ip}"; then
        ((processed += 1))
    else
        ((errors += 1))
    fi
    printf '\n'
done <<< "${clusters}"

printf 'Résumé         : %d enregistrement(s) traité(s), %d erreur(s)\n' \
    "${processed}" "${errors}"

if ((errors > 0)); then
    exit 1
fi

if ((processed == 0)); then
    printf 'Aucun enregistrement n’a été traité. Les Gateway sont-elles prêtes ?\n' >&2
    exit 1
fi
