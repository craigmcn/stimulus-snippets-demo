class DemosController < ApplicationController
  DEMOS = [
    { id: "accordion", title: "Accordion" },
    { id: "character-count", title: "Character Count" },
    { id: "checkbox-required", title: "Checkbox Required" },
    { id: "clipboard", title: "Clipboard" },
    { id: "datetime-local", title: "Datetime Local" },
    { id: "dependent-select", title: "Dependent Select" },
    { id: "direct-upload-progress", title: "Direct Upload Progress" },
    { id: "dismiss", title: "Dismiss" },
    { id: "file-preview", title: "File Preview" },
    { id: "form-confirm", title: "Form Confirm" },
    { id: "match-validator", title: "Match Validator" },
    { id: "number-format", title: "Number Format" },
    { id: "password-reveal", title: "Password Reveal" },
    { id: "password-rules", title: "Password Rules" },
    { id: "relative-time", title: "Relative Time" },
    { id: "responsive-disable", title: "Responsive Disable" },
    { id: "row-select", title: "Row Select" },
    { id: "search-filter", title: "Search Filter" },
    { id: "slug", title: "Slug" },
    { id: "table-sort", title: "Table Sort" },
    { id: "tabs", title: "Tabs" },
    { id: "unsaved-changes", title: "Unsaved Changes" }
  ].freeze

  def index
    @demos = DEMOS
  end

  def show
    @demos = DEMOS
    @demo = DEMOS.find { |demo| demo[:id] == params[:id] }
    raise ActionController::RoutingError, "Not Found" unless @demo

    render @demo[:id]
  end
end
