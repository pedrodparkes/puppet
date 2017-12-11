#== mcpuppet::params
#
class mcpuppet::params {
	$repo_dir = "/etc/puppetlabs/code/environments/dev"
    $ensure   = latest
    $source   = undef
    $revision = 'master'
    $autosign = false
}