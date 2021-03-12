# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Models
    module SpecificationHandlers
      class DefaultTest < MiniTest::Test
        include ExtensionTestHelpers::TestExtensionSetup

        def test_can_load_type_by_identifier
          assert_equal(
            @test_extension_type.identifier,
            Extension.specifications[@test_extension_type.identifier].identifier
          )
        end

        def test_valid_determines_if_a_type_is_valid
          assert Extension.specifications.valid?(ExtensionTestHelpers::TestExtension::IDENTIFIER)
          refute Extension.specifications.valid?("INVALID")
        end

        def test_tagline_returns_empty_string_if_not_defined_in_content
          base_type = Default.new(specification)
          base_type.stubs(:identifier).returns("INVALID")

          assert_equal "", base_type.tagline
        end

        def test_valid_extension_contexts_returns_empty_array
          assert_empty(Default.new(specification).valid_extension_contexts)
        end

        def test_extension_context_returns_nil
          assert_nil(Default.new(specification).extension_context(@context))
        end

        def test_graphql_identifier_is_upcased
          assert_equal specification.identifier.upcase, Default.new(specification).graphql_identifier
        end

        private

        def specification
          Models::Specification.new(identifier: "test_extension")
        end
      end
    end
  end
end