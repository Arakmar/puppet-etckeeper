# @summary Quotes a value for etckeeper.conf, which etckeeper sources with sh.
#
# @api private
#
# @param value
#   The value to quote, undef being an empty string.
#
# @return [String[2]]
#   The value between double quotes, with `\`, `"`, `$` and `` ` `` escaped.
function etckeeper::shell_quote(Optional[String] $value) >> String[2] {
  $escaped = String($value).regsubst(/([\\"$`])/, '\\\\\1', 'G')
  "\"${escaped}\""
}
