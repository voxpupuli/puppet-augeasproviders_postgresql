# frozen_string_literal: true

require 'fixtures/modules/augeasproviders_core/spec/support/spec/psh_fixtures'
require 'augeas_spec'

# augeasproviders: setting $LOAD_PATH to work around broken type autoloading'
$LOAD_PATH.unshift(File.join(__dir__, 'fixtures/modules/augeasproviders_core/lib'))
