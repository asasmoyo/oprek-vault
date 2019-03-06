include_recipe '::nginx'
include_recipe '::postgres'

include_recipe '::consul_template'
include_recipe '::vault_proxy'
