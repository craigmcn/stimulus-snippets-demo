class DemosController < ApplicationController
  DEMOS = [
    { id: "accordion", title: "Accordion" },
    { id: "character-count", title: "Character Count" },
    { id: "checkbox-required", title: "Checkbox Required" },
    { id: "clipboard", title: "Clipboard" },
    { id: "dependent-select", title: "Dependent Select" },
    { id: "dismiss", title: "Dismiss" },
    { id: "file-preview", title: "File Preview" },
    { id: "form-confirm", title: "Form Confirm" },
    { id: "password-reveal", title: "Password Reveal" },
    { id: "password-rules", title: "Password Rules" },
    { id: "search-filter", title: "Search Filter" },
    { id: "slug", title: "Slug" },
    { id: "tabs", title: "Tabs" }
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
