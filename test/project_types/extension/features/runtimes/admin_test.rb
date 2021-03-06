# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    module Runtimes
      class AdminTest < MiniTest::Test
        include ExtensionTestHelpers::TempProjectSetup

        def test_available_flags_are_supported_for_admin
          flags = [
            :api_key,
            :name,
            :port,
            :public_url,
            :renderer_version,
            :resource_url,
            :shop,
            :uuid,
          ]

          flags.each do |flag|
            assert_equal runtime.supports?(flag), supported
          end
        end

        def test_unsupported_flag_is_not_supported_for_admin
          assert_equal runtime.supports?(:fake_flag), not_supported
        end

        def test_active_runtime_returns_true_for_valid_identifier_and_package_name
          active_runtime = runtime.active_runtime?(cli_package, "PRODUCT_SUBSCRIPTION")
          assert_equal active_runtime, active
        end

        def test_active_runtime_returns_false_for_invalid_identifier_and_package_name
          invalid_package = Models::NpmPackage.new(name: "invalid-package", version: "0.11.0")
          active_runtime = runtime.active_runtime?(invalid_package, "INVALID_IDENTIFIER")
          assert_equal active_runtime, inactive
        end

        def test_active_runtime_returns_false_for_invalid_identifier
          active_runtime = runtime.active_runtime?(cli_package, "INVALID_IDENTIFIER")
          assert_equal active_runtime, inactive
        end

        def test_active_runtime_returns_false_for_invalid_package
          invalid_package = Models::NpmPackage.new(name: "invalid-package", version: "0.11.0")
          active_runtime = runtime.active_runtime?(invalid_package, "PRODUCT_SUBSCRIPTION")
          assert_equal active_runtime, inactive
        end

        private

        def supported
          true
        end

        def active
          true
        end

        def not_supported
          false
        end

        def inactive
          false
        end

        def runtime
          @runtime ||= Runtimes::Admin.new
        end

        def cli_package
          Models::NpmPackage.new(name: "@shopify/admin-ui-extensions-run", version: "0.11.0")
        end
      end
    end
  end
end
