#!/usr/bin/env bash
set -euo pipefail

DOMAIN="https://best-tour-operators-falkland-islands.com"
HEADER="components/header.html"
FOOTER="components/footer.html"
TMP_HEADER="/tmp/btofki_header.html"
TMP_FOOTER="/tmp/btofki_footer.html"
TMP_CONTENT="/tmp/btofki_content.html"

# ─── build_page ───────────────────────────────────────────────────────────────
# Args:
#   $1  TITLE          — <title> text
#   $2  META_DESC      — meta description (≤160 chars)
#   $3  CANONICAL      — full canonical URL
#   $4  ACTIVE_NAV     — nav href to mark active (e.g. "/", "/faq/")
#   $5  SCHEMA         — JSON-LD string (pass via variable, never heredoc)
#   $6  CONTENT_FILE   — path to content fragment
#   $7  OUT            — output path
#   $8  DEPTH          — 0=root, 1=subdir
#   $9  OG_TITLE       — og:title (optional, defaults to TITLE)
#   $10 OG_DESC        — og:description (optional, defaults to META_DESC)
# ─────────────────────────────────────────────────────────────────────────────
build_page() {
  local TITLE="$1"
  local META_DESC="$2"
  local CANONICAL="$3"
  local ACTIVE_NAV="$4"
  local SCHEMA="$5"
  local CONTENT_FILE="$6"
  local OUT="$7"
  local DEPTH="$8"
  local OG_TITLE="${9:-$TITLE}"
  local OG_DESC="${10:-$META_DESC}"

  # Compute BASE path for relative assets
  if [ "$DEPTH" -eq 0 ]; then
    BASE=""
    ROOT_HREF="./"
  else
    BASE="../"
    ROOT_HREF="../"
  fi

  # Process header: inject active nav class + convert absolute paths
  sed \
    -e "s|<li><a href=\"${ACTIVE_NAV}\"|<li><a href=\"${ACTIVE_NAV}\" class=\"active\"|g" \
    -e "s|href=\"/\"|href=\"${ROOT_HREF}\"|g" \
    -e "s|href=\"/\([^\"]*\)\"|href=\"${BASE}\1\"|g" \
    -e "s|src=\"/\([^\"]*\)\"|src=\"${BASE}\1\"|g" \
    "$HEADER" > "$TMP_HEADER"

  # Process footer: convert absolute paths only
  sed \
    -e "s|href=\"/\"|href=\"${ROOT_HREF}\"|g" \
    -e "s|href=\"/\([^\"]*\)\"|href=\"${BASE}\1\"|g" \
    -e "s|src=\"/\([^\"]*\)\"|src=\"${BASE}\1\"|g" \
    "$FOOTER" > "$TMP_FOOTER"

  # Process content: convert absolute paths
  sed \
    -e "s|href=\"/\"|href=\"${ROOT_HREF}\"|g" \
    -e "s|href=\"/\([^\"]*\)\"|href=\"${BASE}\1\"|g" \
    -e "s|src=\"/\([^\"]*\)\"|src=\"${BASE}\1\"|g" \
    "$CONTENT_FILE" > "$TMP_CONTENT"

  # Assemble full page
  {
    cat <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${TITLE}</title>
  <meta name="description" content="${META_DESC}">
  <link rel="canonical" href="${CANONICAL}">
  <meta property="og:type" content="article">
  <meta property="og:title" content="${OG_TITLE}">
  <meta property="og:description" content="${OG_DESC}">
  <meta property="og:url" content="${CANONICAL}">
  <meta property="og:site_name" content="Falklands Tour Guide">
  <meta name="robots" content="index, follow">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garant:ital,wght@0,400;0,600;0,700;1,400;1,600&family=DM+Sans:wght@400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${BASE}css/global.css">
  <link rel="stylesheet" href="${BASE}css/ranking.css">
  <link rel="icon" type="image/svg+xml" href="${BASE}images/favicon.svg">
HTML
    if [ -n "$SCHEMA" ]; then
      printf '<script type="application/ld+json">\n%s\n</script>\n' "$SCHEMA"
    fi
    echo '</head>'
    echo '<body>'
    cat "$TMP_HEADER"
    echo '<main id="main-content">'
    cat "$TMP_CONTENT"
    echo '</main>'
    cat "$TMP_FOOTER"
    echo '</body>'
    echo '</html>'
  } > "$OUT"

  echo "  Built: $OUT"
}

# ─────────────────────────────────────────────────────────────────────────────
# SCHEMAS
# ─────────────────────────────────────────────────────────────────────────────

# Main page schema
SCHEMA_INDEX=$(cat <<'JSONLD'
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "WebPage",
      "@id": "https://best-tour-operators-falkland-islands.com/",
      "url": "https://best-tour-operators-falkland-islands.com/",
      "name": "Best Tour Operators Falkland Islands 2026 – Verified Guide",
      "description": "Compare the 10 best tour operators for the Falkland Islands in 2026. Expedition cruises + local Stanley guides, prices, reviews and expert tips.",
      "datePublished": "2026-01-01",
      "dateModified": "2026-06-24",
      "author": {"@type": "Organization", "name": "Falklands Tour Guide Editorial Team"},
      "inLanguage": "en"
    },
    {
      "@type": "ItemList",
      "name": "Best Tour Operators for the Falkland Islands 2026",
      "url": "https://best-tour-operators-falkland-islands.com/",
      "numberOfItems": 10,
      "itemListElement": [
        {"@type": "ListItem", "position": 1, "name": "Poseidon Expeditions", "url": "https://poseidonexpeditions.com/antarctica/falklands-south-georgia-best-southern-ocean/"},
        {"@type": "ListItem", "position": 2, "name": "HX Expeditions", "url": "https://www.hxexpeditions.com/"},
        {"@type": "ListItem", "position": 3, "name": "G Adventures", "url": "https://www.gadventures.com/"},
        {"@type": "ListItem", "position": 4, "name": "Quark Expeditions", "url": "https://www.quarkexpeditions.com/"},
        {"@type": "ListItem", "position": 5, "name": "Audley Travel", "url": "https://www.audleytravel.com/"},
        {"@type": "ListItem", "position": 6, "name": "Falkland Islands Holidays", "url": "https://www.falklandislandsholidays.com/"},
        {"@type": "ListItem", "position": 7, "name": "Discovery Falklands", "url": "https://www.discoveryfalklands.com/"},
        {"@type": "ListItem", "position": 8, "name": "International Tours & Travel (ITT)", "url": "https://www.falklandislands-itt.com/"},
        {"@type": "ListItem", "position": 9, "name": "Kidney Cove Tours", "url": "https://www.falklandislands.com/"},
        {"@type": "ListItem", "position": 10, "name": "Falkland Islands Tours & Travel (FITT)", "url": "https://www.falklandislands.com/"}
      ]
    },
    {
      "@type": "TouristAttraction",
      "name": "Volunteer Point",
      "description": "Important Bird Area designated by BirdLife International. Home to approximately 150 king penguin breeding pairs, the most northerly accessible king penguin colony.",
      "url": "https://best-tour-operators-falkland-islands.com/#local",
      "geo": {"@type": "GeoCoordinates", "latitude": -51.47, "longitude": -58.39},
      "containedInPlace": {"@type": "Country", "name": "Falkland Islands"}
    },
    {
      "@type": "FAQPage",
      "mainEntity": [
        {
          "@type": "Question",
          "name": "What is the best time to visit the Falkland Islands?",
          "acceptedAnswer": {"@type": "Answer", "text": "The optimal window is October to February (austral spring and summer). Wildlife activity peaks during this period — king penguin chicks hatch, seal pups are born, and albatross conduct courtship. The Falkland Islands Tourist Board recommends October–February for all wildlife-focused visits."}
        },
        {
          "@type": "Question",
          "name": "How do I get to the Falkland Islands?",
          "acceptedAnswer": {"@type": "Answer", "text": "By air: LATAM Airlines operates weekly flights from Punta Arenas, Chile to Stanley (MPN). ITT is the LATAM GSA for the Falklands. By expedition ship: most cruises depart from Ushuaia, Argentina, reaching the Falklands in 36-48 hours."}
        },
        {
          "@type": "Question",
          "name": "Which operator is best for seeing king penguins?",
          "acceptedAnswer": {"@type": "Answer", "text": "For king penguins from land: Volunteer Point with guide Patrick Watts — book 12-18 months in advance. Volunteer Point hosts approximately 150 breeding pairs designated as an IBA by BirdLife International. By expedition cruise, Poseidon Expeditions visits South Georgia king penguin colonies on its 19-day Falklands + South Georgia voyage."}
        },
        {
          "@type": "Question",
          "name": "Can I visit the Falkland Islands without an expedition cruise?",
          "acceptedAnswer": {"@type": "Answer", "text": "Yes. Five Stanley-based operators serve land visitors: Falkland Islands Holidays (bespoke), Discovery Falklands (wildlife + 1982 war history), ITT (since 1995, LATAM flights), Kidney Cove Tours (penguin-focused), and FITT (cruise stopovers, vehicle rental)."}
        },
        {
          "@type": "Question",
          "name": "How far in advance should I book a Falkland Islands tour?",
          "acceptedAnswer": {"@type": "Answer", "text": "Volunteer Point tours with Patrick Watts: 12-18 months. Expedition cruises: 6-12 months for preferred dates. General Stanley tours: 2-3 months."}
        },
        {
          "@type": "Question",
          "name": "Is it worth combining the Falkland Islands with South Georgia?",
          "acceptedAnswer": {"@type": "Answer", "text": "Yes. South Georgia adds Shackleton's grave, 250,000+ king penguins at Salisbury Plain, and dramatic sub-Antarctic scenery — almost always bundled in the same expedition itinerary as the Falklands."}
        },
        {
          "@type": "Question",
          "name": "What is Volunteer Point?",
          "acceptedAnswer": {"@type": "Answer", "text": "Volunteer Point is a headland on East Falkland designated by BirdLife International as an Important Bird Area. It hosts approximately 150 king penguin breeding pairs — the most northerly accessible king penguin colony in the world. Access via 4WD (2 hours from Stanley) or helicopter (15 minutes). Book Patrick Watts 12-18 months ahead."}
        },
        {
          "@type": "Question",
          "name": "Are the Falkland Islands suitable for solo travellers?",
          "acceptedAnswer": {"@type": "Answer", "text": "Yes. Expedition cruises are naturally social for solo travellers. Poseidon Expeditions and G Adventures accept solo bookings. For land-based travel, Stanley-based operators (Discovery Falklands, FITT) run small-group departures suitable for solo visitors."}
        }
      ]
    }
  ]
}
JSONLD
)

# About schema
SCHEMA_ABOUT=$(cat <<'JSONLD'
{
  "@context": "https://schema.org",
  "@type": "AboutPage",
  "url": "https://best-tour-operators-falkland-islands.com/about/",
  "name": "About — Falklands Tour Guide",
  "description": "About this independent editorial resource comparing Falkland Islands tour operators.",
  "breadcrumb": {
    "@type": "BreadcrumbList",
    "itemListElement": [
      {"@type": "ListItem", "position": 1, "name": "Home", "item": "https://best-tour-operators-falkland-islands.com/"},
      {"@type": "ListItem", "position": 2, "name": "About", "item": "https://best-tour-operators-falkland-islands.com/about/"}
    ]
  }
}
JSONLD
)

# Methodology schema
SCHEMA_METHOD=$(cat <<'JSONLD'
{
  "@context": "https://schema.org",
  "@type": "WebPage",
  "url": "https://best-tour-operators-falkland-islands.com/methodology/",
  "name": "Our Methodology — Falklands Tour Guide",
  "description": "How we score and rank Falkland Islands tour operators. Five criteria, transparent weights, annual review.",
  "breadcrumb": {
    "@type": "BreadcrumbList",
    "itemListElement": [
      {"@type": "ListItem", "position": 1, "name": "Home", "item": "https://best-tour-operators-falkland-islands.com/"},
      {"@type": "ListItem", "position": 2, "name": "Methodology", "item": "https://best-tour-operators-falkland-islands.com/methodology/"}
    ]
  }
}
JSONLD
)

# FAQ schema
SCHEMA_FAQ=$(cat <<'JSONLD'
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "url": "https://best-tour-operators-falkland-islands.com/faq/",
  "name": "Falkland Islands Tour FAQ",
  "mainEntity": [
    {"@type": "Question", "name": "What is the best time to visit the Falkland Islands?", "acceptedAnswer": {"@type": "Answer", "text": "October to February (austral spring and summer) is optimal. Wildlife activity peaks November–January."}},
    {"@type": "Question", "name": "How do I get to the Falkland Islands?", "acceptedAnswer": {"@type": "Answer", "text": "By air via LATAM Airlines from Punta Arenas, Chile. By expedition ship from Ushuaia, Argentina."}},
    {"@type": "Question", "name": "Do I need a visa to visit the Falkland Islands?", "acceptedAnswer": {"@type": "Answer", "text": "Most nationalities do not require a pre-arranged visa for tourist visits up to 4 weeks. Check with the Falkland Islands Government (fig.gov.fk)."}},
    {"@type": "Question", "name": "What is Volunteer Point?", "acceptedAnswer": {"@type": "Answer", "text": "A BirdLife International IBA on East Falkland with ~150 king penguin breeding pairs. Book guide Patrick Watts 12-18 months ahead."}},
    {"@type": "Question", "name": "Is South Georgia worth adding?", "acceptedAnswer": {"@type": "Answer", "text": "Yes — it adds Shackleton's grave, 250,000+ king penguins, and fur seals. Almost always bundled with Falklands in expedition itineraries."}}
  ]
}
JSONLD
)

# Editorial policy schema
SCHEMA_EDIT=$(cat <<'JSONLD'
{
  "@context": "https://schema.org",
  "@type": "WebPage",
  "url": "https://best-tour-operators-falkland-islands.com/editorial-policy/",
  "name": "Editorial Policy — Falklands Tour Guide",
  "description": "Our editorial policy: operator selection criteria, ranking transparency, no sponsored placements."
}
JSONLD
)

# Contact schema
SCHEMA_CONTACT=$(cat <<'JSONLD'
{
  "@context": "https://schema.org",
  "@type": "ContactPage",
  "url": "https://best-tour-operators-falkland-islands.com/contact/",
  "name": "Contact — Falklands Tour Guide"
}
JSONLD
)

# ─────────────────────────────────────────────────────────────────────────────
# BUILD ALL PAGES
# ─────────────────────────────────────────────────────────────────────────────
echo "Building best-tour-operators-falkland-islands.com..."
echo ""

build_page \
  "Best Tour Operators Falkland Islands 2026 – Verified Guide" \
  "Compare the 10 best tour operators for the Falkland Islands in 2026. Expedition cruises + local Stanley guides, prices, reviews and expert tips." \
  "${DOMAIN}/" \
  "/" \
  "$SCHEMA_INDEX" \
  "content/main-ranking.html" \
  "index.html" \
  0 \
  "Best Tour Operators Falkland Islands 2026 – Verified Guide" \
  "Compare the 10 best tour operators for the Falkland Islands in 2026."

mkdir -p about
build_page \
  "About — Falklands Tour Guide" \
  "About this independent editorial resource comparing Falkland Islands tour operators. No sponsored placements, verified rankings." \
  "${DOMAIN}/about/" \
  "/about/" \
  "$SCHEMA_ABOUT" \
  "content/about.html" \
  "about/index.html" \
  1

mkdir -p editorial-policy
build_page \
  "Editorial Policy — Falklands Tour Guide" \
  "How we select and rank Falkland Islands tour operators. Transparent criteria, no paid placements, annual review cycle." \
  "${DOMAIN}/editorial-policy/" \
  "/editorial-policy/" \
  "$SCHEMA_EDIT" \
  "content/editorial-policy.html" \
  "editorial-policy/index.html" \
  1

mkdir -p methodology
build_page \
  "Methodology — How We Rank Falkland Islands Tour Operators" \
  "Our scoring rubric for ranking Falkland Islands tour operators. Five criteria with defined weights, verified data sources." \
  "${DOMAIN}/methodology/" \
  "/methodology/" \
  "$SCHEMA_METHOD" \
  "content/methodology.html" \
  "methodology/index.html" \
  1

mkdir -p faq
build_page \
  "Falkland Islands Tour FAQ – 15 Essential Questions Answered" \
  "Answers to the most common questions about visiting and booking tours in the Falkland Islands. Best time, getting there, king penguins, costs." \
  "${DOMAIN}/faq/" \
  "/faq/" \
  "$SCHEMA_FAQ" \
  "content/faq.html" \
  "faq/index.html" \
  1

mkdir -p contact
build_page \
  "Contact — Falklands Tour Guide" \
  "Corrections, operator updates, and editorial enquiries. We respond within 48 hours." \
  "${DOMAIN}/contact/" \
  "/contact/" \
  "$SCHEMA_CONTACT" \
  "content/contact.html" \
  "contact/index.html" \
  1

echo ""
echo "Done. Pages built:"
echo "  index.html"
echo "  about/index.html"
echo "  editorial-policy/index.html"
echo "  methodology/index.html"
echo "  faq/index.html"
echo "  contact/index.html"
