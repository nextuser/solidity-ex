```puml
Client ->TestTransfer:sendOut
TestTransfer ->TransferCount: transfer
TransferCount->TransferCount:receive
note over TransferCount: 因为receive 有计算,导致gas不足,\n在TestTransfer中调用address(TransferCount).transfer失败

```