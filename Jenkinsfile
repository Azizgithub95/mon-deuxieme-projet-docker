     stage('Tests') {
       parallel {
         // … Cypress reste inchangé …

+        stage('Newman') {
+          agent {
+            docker {
+              image 'postman/newman:alpine'
+              // on monte $WORKSPACE et on y place évidemment le bon WD
+              args  "--entrypoint='' " +
+                    "-v ${WORKSPACE}:${WORKSPACE} " +
+                    "-w ${WORKSPACE}"
+            }
+          }
+          steps {
+            echo '--- Running Newman tests ---'
+            sh '''
+              mkdir -p reports/newman
+              # Le chemin relatif doit maintenant être trouvé
+              newman run collections/MOCK_AZIZ_SERVEUR.postman_collection.json \
+                --reporters cli,html \
+                --reporter-html-export reports/newman/newman-report.html
+            '''
+          }
+        }
+
+        stage('K6') {
+          agent {
+            docker {
+              image 'grafana/k6'
+              args  "--entrypoint='' " +
+                    "-v ${WORKSPACE}:${WORKSPACE} " +
+                    "-w ${WORKSPACE}"
+            }
+          }
+          steps {
+            echo '--- Running K6 tests ---'
+            sh '''
+              mkdir -p reports/k6
+              # on exécute via le bon WD
+              k6 run tests/test_k6.js
+            '''
+          }
+        }
       }
     }
