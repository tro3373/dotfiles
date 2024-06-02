if ! has('nvim') || !g:plug.is_installed("nvim-jdtls")
  finish
endif
finish

local home = '/Users/marcin'
local java_path = home .. '/data/amazon-corretto-17.jdk/Contents/Home/bin/java'
-- local java_path = '/Users/marcin/data/jdk-20.0.2.jdk/Contents/Home/bin/java'
local current_system = 'mac_arm'
local mason_packages = home .. '/.local/share/nvim/mason/packages'
local equinox_launcher = vim.fn.glob( mason_packages .. '/jdtls/plugins/org.eclipse.equinox.launcher_*.jar' )
local ms_java_debug = vim.fn.glob( mason_packages .. '/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar')

local workspace_path = home .. '/.local/share/nvim/java-workspaces/'
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = workspace_path .. project_name

local jdtls = require( 'jdtls' )
local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

local config = {
    cmd = {
        java_path,
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens',
        'java.base/java.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang=ALL-UNNAMED',
        "-javaagent:" .. mason_packages .. '/jdtls/lombok.jar',
        '-jar', equinox_launcher,
        '-configuration', mason_packages .. '/jdtls/config_' .. current_system,
        '-data', workspace_dir
    },
    root_dir = require( 'jdtls.setup' ).find_root( { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' } ),

    settings = {
        java = {
            eclipse = {
                downloadSources = true,
            },
            configuration = {
                updateBuildConfiguration = 'interactive',
            },
            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            inlayHints = {
                parameterNames = {
                    enabled = "all",
                },
            },
            contentProvider = {
                preferred = 'fernflower'
            },
            format = {
                enabled = false,
            },
        },
        signatureHelp = { enabled = true },
        extendedClientCapabilities = extendedClientCapabilities,
    },

    init_options = {
        bundles = {
            ms_java_debug,
            home .. '/data/vscode-java-decompiler/server/dg.jdt.ls.decompiler.cfr-0.0.3.jar',
            home .. '/data/vscode-java-decompiler/server/dg.jdt.ls.decompiler.common-0.0.3.jar',
            home .. '/data/vscode-java-decompiler/server/dg.jdt.ls.decompiler.fernflower-0.0.3.jar',
            home .. '/data/vscode-java-decompiler/server/dg.jdt.ls.decompiler.procyon-0.0.3.jar',
        }
    },
}

jdtls.start_or_attach( config )
jdtls.setup_dap( { hotcodereplace = 'auto' } )

