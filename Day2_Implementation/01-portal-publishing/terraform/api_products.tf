# Accounts API
resource "konnect_api" "accounts" {
  name = "Accounts API"
}

resource "konnect_api_specification" "accounts_spec" {
  api_id  = konnect_api.accounts.id
  content = file("../../gitops-monorepo/api-specs/openapi-specs/accounts_api.yaml")
}

resource "konnect_api_implementation" "accounts" {
  api_id = konnect_api.accounts.id
  service_reference = {
    service = {
      id = var.svc_accounts_id
      control_plane_id = var.cp_core_id
    }
  }
}

resource "konnect_api_publication" "accounts" {
  api_id    = konnect_api.accounts.id
  portal_id = var.portal_id
}

resource "konnect_api_document" "accounts_terms" {
  api_id  = konnect_api.accounts.id
  title   = "Terms and Conditions"
  slug    = "terms"
  status  = "published"
  content = file("../../../Day1_Discovery/elaborados/openapi_specs/accounts_terms.md")
}

resource "konnect_api_document" "accounts_manual" {
  api_id  = konnect_api.accounts.id
  title   = "User Manual"
  slug    = "manual"
  status  = "published"
  content = file("../../../Day1_Discovery/elaborados/openapi_specs/accounts_manual.md")
}

# Credit Card Transactions API
resource "konnect_api" "transactions" {
  name = "Credit Card Transactions API"
}

resource "konnect_api_specification" "transactions_spec" {
  api_id  = konnect_api.transactions.id
  content = file("../../gitops-monorepo/api-specs/openapi-specs/transactions_api.yaml")
}

resource "konnect_api_implementation" "transactions" {
  api_id = konnect_api.transactions.id
  service_reference = {
    service = {
      id = var.svc_credit_accounts_id
      control_plane_id = var.cp_credit_cards_id
    }
  }
}

resource "konnect_api_publication" "transactions" {
  api_id    = konnect_api.transactions.id
  portal_id = var.portal_id
}

resource "konnect_api_document" "transactions_terms" {
  api_id  = konnect_api.transactions.id
  title   = "Terms and Conditions"
  slug    = "terms"
  status  = "published"
  content = file("../../../Day1_Discovery/elaborados/openapi_specs/transactions_terms.md")
}

resource "konnect_api_document" "transactions_manual" {
  api_id  = konnect_api.transactions.id
  title   = "User Manual"
  slug    = "manual"
  status  = "published"
  content = file("../../../Day1_Discovery/elaborados/openapi_specs/transactions_manual.md")
}

# Payments API
resource "konnect_api" "payments" {
  name = "Payments API"
}

resource "konnect_api_specification" "payments_spec" {
  api_id  = konnect_api.payments.id
  content = file("../../gitops-monorepo/api-specs/openapi-specs/payments_api.yaml")
}

resource "konnect_api_publication" "payments" {
  api_id    = konnect_api.payments.id
  portal_id = var.portal_id
}

resource "konnect_api_document" "payments_terms" {
  api_id  = konnect_api.payments.id
  title   = "Terms and Conditions"
  slug    = "terms"
  status  = "published"
  content = file("../../../Day1_Discovery/elaborados/openapi_specs/payments_terms.md")
}

resource "konnect_api_document" "payments_manual" {
  api_id  = konnect_api.payments.id
  title   = "User Manual"
  slug    = "manual"
  status  = "published"
  content = file("../../../Day1_Discovery/elaborados/openapi_specs/payments_manual.md")
}

# Open Banking Consent API
resource "konnect_api" "open_banking_consent" {
  name = "Open Banking Consent API"
}

resource "konnect_api_specification" "open_banking_consent_spec" {
  api_id  = konnect_api.open_banking_consent.id
  content = file("../../gitops-monorepo/api-specs/openapi-specs/open_banking_consent_api.yaml")
}

resource "konnect_api_publication" "open_banking_consent" {
  api_id    = konnect_api.open_banking_consent.id
  portal_id = var.portal_id
}

resource "konnect_api_document" "open_banking_consent_terms" {
  api_id  = konnect_api.open_banking_consent.id
  title   = "Terms and Conditions"
  slug    = "terms"
  status  = "published"
  content = file("../../../Day1_Discovery/elaborados/openapi_specs/open_banking_consent_terms.md")
}

resource "konnect_api_document" "open_banking_consent_manual" {
  api_id  = konnect_api.open_banking_consent.id
  title   = "User Manual"
  slug    = "manual"
  status  = "published"
  content = file("../../../Day1_Discovery/elaborados/openapi_specs/open_banking_consent_manual.md")
}

# Loans API
resource "konnect_api" "loans" {
  name = "Loans API"
}

resource "konnect_api_specification" "loans_spec" {
  api_id  = konnect_api.loans.id
  content = file("../../gitops-monorepo/api-specs/openapi-specs/loan_origination_api.yaml")
}

resource "konnect_api_implementation" "loans" {
  api_id = konnect_api.loans.id
  service_reference = {
    service = {
      id = var.svc_loans_id
      control_plane_id = var.cp_loans_id
    }
  }
}

resource "konnect_api_document" "loans_terms" {
  api_id  = konnect_api.loans.id
  title   = "Terms and Conditions"
  slug    = "terms"
  status  = "unpublished"
  content = file("../../../Day1_Discovery/elaborados/openapi_specs/loans_terms.md")
}

resource "konnect_api_document" "loans_manual" {
  api_id  = konnect_api.loans.id
  title   = "User Manual"
  slug    = "manual"
  status  = "unpublished"
  content = file("../../../Day1_Discovery/elaborados/openapi_specs/loans_manual.md")
}

# Card Issuance API
resource "konnect_api" "card_issuance" {
  name = "Card Issuance API"
}

resource "konnect_api_specification" "card_issuance_spec" {
  api_id  = konnect_api.card_issuance.id
  content = file("../../gitops-monorepo/api-specs/openapi-specs/card_issuance_api.yaml")
}

# Customer Onboarding API
resource "konnect_api" "customer_onboarding" {
  name = "Customer Onboarding API"
}

resource "konnect_api_specification" "customer_onboarding_spec" {
  api_id  = konnect_api.customer_onboarding.id
  content = file("../../gitops-monorepo/api-specs/openapi-specs/customer_onboarding_api.yaml")
}

# Fraud Analysis API
resource "konnect_api" "fraud_analysis" {
  name = "Fraud Analysis API"
}

resource "konnect_api_specification" "fraud_analysis_spec" {
  api_id  = konnect_api.fraud_analysis.id
  content = file("../../gitops-monorepo/api-specs/openapi-specs/fraud_analysis_api.yaml")
}

# Partner Statement API
resource "konnect_api" "partner_statement" {
  name = "Partner Statement API"
}

resource "konnect_api_specification" "partner_statement_spec" {
  api_id  = konnect_api.partner_statement.id
  content = file("../../gitops-monorepo/api-specs/openapi-specs/partner_statement_api.yaml")
}

# Support Chatbot API
resource "konnect_api" "support_chatbot" {
  name = "Support Chatbot API"
}

resource "konnect_api_specification" "support_chatbot_spec" {
  api_id  = konnect_api.support_chatbot.id
  content = file("../../gitops-monorepo/api-specs/openapi-specs/support_chatbot_api.yaml")
}

