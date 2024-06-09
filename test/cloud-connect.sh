#!/bin/bash

az login \
	--service-principal \
	--user "${ARM_CLIENT_ID}" \
	--password "${ARM_CLIENT_SECRET}" \
	--tenant "${ARM_TENANT_ID}"
az account set \
	--subscription "${ARM_SUBSCRIPTION_ID}"
