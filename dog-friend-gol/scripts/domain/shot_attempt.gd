class_name ShotAttempt
## Uma cobrança individual (data-model.md). Registra as duas escolhas e o resultado.
## Domínio puro (Artigo IV).

var round: int = 1            ## ≥ 1
var shooter_index: int = 0    ## 0 ou 1
var shooter_zone: int = ShotZone.Zone.MIDDLE_CENTER  ## uma das 9
var defender_zone: int = ShotZone.Zone.MIDDLE_CENTER ## uma das 9
var result: int = ShotResult.Result.DEFENDED         ## derivado, nunca atribuído livremente
