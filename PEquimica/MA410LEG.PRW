#INCLUDE 'protheus.ch'

User Function MA410LEG()

Local aLegenda := {}

AADD(aLegenda,{'ENABLE' ,"Pedido de Venda em aberto"})
AADD(aLegenda,{'DISABLE' ,"Pedido de Venda encerrado"})
AADD(aLegenda,{'BR_AMARELO',"Pedido de Venda liberado" })
AADD(aLegenda,{'BR_AZUL' ,"Pedido de Venda com Bloqueio de Regra"})
AADD(aLegenda,{'BR_LARANJA',"Pedido de Venda com Bloqueio de Verba" })
AADD(aLegenda,{"BR_PRETO" ,"Bloqueio de Estoque"})
AADD(aLegenda,{"BR_BRANCO" ,"Bloqueio de Credito"})
AADD(aLegenda,{"BR_VIOLETA" ,"Bloqueio de Credito/Estoque"})

Return(aLegenda)
