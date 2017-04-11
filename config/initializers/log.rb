Pliny.default_context = { app: "telex" }

Pliny.log_scrubber = BlacklistHash.build(fields_to_scrub: Rollbar::Blanket.fields)

BlacklistHash.default_fields = Rollbar::Blanket.fields
