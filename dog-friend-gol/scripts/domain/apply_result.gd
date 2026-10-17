class_name ApplyResult
## Resultado de apply_attempt: o erro (se houver) e os eventos gerados.
## Domínio puro (Artigo IV).

var error: int = ApplyError.Error.NONE
var events: Array = []  ## Array[int] de MatchEvent.Event
