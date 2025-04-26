#!/bin/bash

echo "🧪 Génération des rapports..."

### 1. POSTMAN (Newman)
echo "👉 Génération du rapport HTML pour Newman..."
newman run "MOCK AZIZ SERVEUR.postman_collection.json" \
  -r cli,html \
  --reporter-html-export reports/newman-report.html

### 2. K6
echo "👉 Génération du rapport HTML pour K6..."
k6 run test_k6.js \
  --summary-trend-stats=avg,min,max \
  --out json=reports/k6-summary.json \
  --summary-export=reports/k6-summary-export.json \
  --summary-export=summary.json \
  --summary-trend-stats=avg,min,max \
  --summary-export=tmp.json \
  --summary-export=summary.json \
  --summary-trend-stats=avg,min,max \
  --summary-export=tmp.json \
  --summary-export=summary.json \
  --summary-trend-stats=avg,min,max \
  --summary-export=tmp.json \
  --summary-export=summary.json \
  --summary-trend-stats=avg,min,max \
  --summary-export=tmp.json

k6 run test_k6.js --summary-trend-stats=avg,min,max \
  --summary-export=reports/k6-summary-export.json \
  --summary-export=tmp.json \
  --summary-export=summary.json \
  --summary-trend-stats=avg,min,max \
  --summary-export=tmp.json

k6 run test_k6.js \
  --summary-trend-stats=avg,min,max \
  --summary-export=reports/k6-summary-export.json \
  --summary-export=tmp.json \
  --summary-export=summary.json \
  --summary-trend-stats=avg,min,max \
  --summary-export=tmp.json

echo "✅ Utilisation de summary.js pour le rapport HTML de K6..."
k6 run test_k6.js --summary-trend-stats=avg,min,max \
  --summary-export=reports/k6-summary-export.json \
  --summary-export=tmp.json \
  --summary-export=summary.json \
  --summary-trend-stats=avg,min,max \
  --summary-export=tmp.json \
  --summary-export=summary.json \
  --summary-trend-stats=avg,min,max \
  --summary-export=tmp.json \
  --summary-export=summary.json \
  --summary-trend-stats=avg,min,max \
  --summary-export=tmp.json \
  --summary-export=summary.json \
  --summary-trend-stats=avg,min,max \
  --summary-export=tmp.json \
  --summary-export=summary.json

### 3. CYPRESS
echo "👉 Lancement des tests Cypress avec rapport Mochawesome..."
npx cypress run --reporter mochawesome \
  --reporter-options reportDir=reports/mochawesome,overwrite=true,html=true,json=false

echo "✅ Tous les rapports ont été générés dans le dossier ./reports"
