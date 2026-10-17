class_name AttemptOutcome
## Resultado completo de uma cobrança, pronto para a apresentação
## (contracts/use-case-api.md §3).

var shooter_index: int = 0       ## quem cobrou
var defender_index: int = 0      ## quem defendeu
var shooter_zone: int = ShotZone.Zone.MIDDLE_CENTER   ## zona do cobrador
var defender_zone: int = ShotZone.Zone.MIDDLE_CENTER  ## zona do defensor
var result: int = ShotResult.Result.DEFENDED          ## GOAL | DEFENDED | OUT_OF_BOUNDS
var state: MatchState = null     ## estado APÓS a cobrança
var events: Array = []           ## Array[int] de MatchEvent.Event
