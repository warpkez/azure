# Resource Groups

To use
`az deployment sub create --location {location} --template-file {template.bicep} --name {name} -o table --parameter ParameterName='value'`

Location is required twice, both by the command itself and the script specification.

A way around this could be:

```
LOCATION=australiaeast

az deployment sub create --location ${LOCATION} --template-file resourcegroup.bicep --name ResourceGroup-${LOCATION} -o table --parameter ResourceRegion='${LOCATION}'
```