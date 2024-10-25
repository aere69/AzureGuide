#!/bin/bash

az monitor metrics list \
    --resource <resource-ID> \
    --metric "Transactions" \
    --interval PT1H \
    --filter "ApiName eq 'GetBlob' " \
    --aggregation "Total"