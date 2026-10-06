#!/usr/bin/env bash
# Create the two Stripe Payment Links for the paid tiers. Idempotent per run: pass --reuse to skip if a
# product with the same lookup metadata exists. Reads STRIPE_SECRET_KEY from the environment; never prints it.
#
#   STRIPE_SECRET_KEY=sk_test_...  tools/create-payment-links.sh      # test-mode links (buy.stripe.com/test_...)
#   STRIPE_SECRET_KEY=sk_live_...  tools/create-payment-links.sh      # live links. A link charges nobody until a customer pays.
#
# Prices (USD, one-time): Harness Pro $99, Done-for-you install $499. Edit PRO_CENTS / INSTALL_CENTS to change.
set -euo pipefail
: "${STRIPE_SECRET_KEY:?set STRIPE_SECRET_KEY in the environment}"
PRO_CENTS="${PRO_CENTS:-9900}"; INSTALL_CENTS="${INSTALL_CENTS:-49900}"
API="https://api.stripe.com/v1"
mode="live"; case "$STRIPE_SECRET_KEY" in *_test_*) mode="test" ;; esac
# Keep the key off argv: pass it through a curl config on stdin.
stripe() { # METHOD PATH [form fields...]
  local m="$1" p="$2"; shift 2
  local args=() f
  for f in "$@"; do args+=(--data-urlencode "$f"); done
  printf 'user = "%s:"\n' "$STRIPE_SECRET_KEY" | curl -sS --config - -X "$m" "$API$p" "${args[@]}"
}
paylink_url() { sed -n 's/.*"url": *"\(https:\/\/buy\.stripe\.com[^"]*\)".*/\1/p' | head -n1; }
jget() { sed -n "s/.*\"$1\": *\"\([^\"]*\)\".*/\1/p" | head -n1; }

make_link() { # name description cents redirect lookup
  local name="$1" desc="$2" cents="$3" redirect="$4" lookup="$5" prod price link
  prod=$(stripe POST /products "name=$name" "description=$desc" "metadata[sku]=$lookup" | jget id)
  [ -n "$prod" ] || { echo "product create failed for $name" >&2; exit 1; }
  price=$(stripe POST /prices "product=$prod" "unit_amount=$cents" "currency=usd" | jget id)
  [ -n "$price" ] || { echo "price create failed for $name" >&2; exit 1; }
  link=$(stripe POST /payment_links "line_items[0][price]=$price" "line_items[0][quantity]=1" \
        "after_completion[type]=redirect" "after_completion[redirect][url]=$redirect" \
        "metadata[sku]=$lookup" "allow_promotion_codes=false" "billing_address_collection=auto")
  printf '%s\t%s\t%s\t%s\n' "$lookup" "$(printf '%s' "$link" | paylink_url)" "$price" "$mode"
}

make_link "MeshVault Harness Pro" "Pro skills pack for the MeshVault Harness: 9 skills, memory templates, runbooks, routing recipes, 12 months of updates. The download link and license key are emailed within minutes of payment." \
  "$PRO_CENTS" "https://thefiredev.com/harness?paid=pro" harness-pro
make_link "MeshVault Harness: Done-for-you install" "One computer you own: 20-minute call, up to 90 minutes screen-share install, one workflow built, 30 days of email support. A confirmation email asks for times to book." \
  "$INSTALL_CENTS" "https://thefiredev.com/harness?paid=install" harness-install
