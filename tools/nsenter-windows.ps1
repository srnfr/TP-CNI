$node=$args[0]
$nodeName=$(kubectl get node ${node} -o=template --template='{{index .metadata.labels \"kubernetes.io/hostname\"}}')

$nodeSelector="`"nodeSelector`": {`"kubernetes.io/hostname`": `"${nodeName}`"},"
$podName="$env:UserName-nsenter-${node}"
$podName=$podName.replace('@', '-')
$podName=$podName.replace('.', '-')
$podName=$podName.subString(0, [System.Math]::Min(63, $podName.Length))


$jsonString = "{""spec"":{""hostPID"":true,""hostNetwork"":true,${nodeSelector}""tolerations"":[{""operator"":""Exists""}],""containers"":[{""name"":""nsenter"",""image"":""alexeiled/nsenter"",""command"":[""/nsenter"",""--all"",""--target=1"",""--"",""su"",""-""],""stdin"":true,""tty"":true,""securityContext"":{""privileged"":true},""resources"":{""requests"":{""cpu"":""10m""}}}]}}" | ConvertTo-Json

kubectl run ${podName} --restart=Never -it --rm --image overriden --overrides=$jsonString
