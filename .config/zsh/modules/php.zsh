## Laravel Aliases
alias c='composer'
alias ccp='composer create-project'
alias cdo='composer dump-autoload -o'
alias cdu='composer dump-autoload'
alias cget='curl -s https://getcomposer.org/installer | php'
alias cgr='composer global require'
alias cgrm='composer global remove'
alias cgu='composer global update'
alias ci='composer install'
alias co='composer outdated'
alias cod='composer outdated --direct'
alias cr='composer require'
alias crm='composer remove'
alias cs='composer show'
alias csu='composer self-update'
alias cu='composer update'
alias cuh='composer update --working-dir=$(composer config -g home)'

alias vbupdate="php upgrade.php"

function php_versions() {
    brew ls --versions | ggrep -E 'php(@.*)?\s' | ggrep -oP '(?<=\s)\d\.\d' | uniq | sort
}

## Manage PHP Versions

# determine versions of PHP installed with HomeBrew
installedPhpVersions=($(brew ls --versions | ggrep -E 'php(@.*)?\s' | ggrep -oP '(?<=\s)\d\.\d' | uniq | sort))

# create alias for every version of PHP installed with HomeBrew
for phpVersion in ${installedPhpVersions[*]}; do
    value="{"

    for otherPhpVersion in ${installedPhpVersions[*]}; do
        if [ "${otherPhpVersion}" = "${phpVersion}" ]; then
            continue
        fi

        # unlink other PHP version
        value="${value} brew unlink php@${otherPhpVersion};"
    done

    # link desired PHP version
    value="${value} brew link php@${phpVersion} --force --overwrite; } &> /dev/null && php -v"

    alias "${phpVersion}"="${value}"
done
