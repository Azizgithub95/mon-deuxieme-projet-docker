import json
import sys
import matplotlib.pyplot as plt

def main():
    input_path = sys.argv[1]   # ex : reports/k6/summary.json
    output_path = sys.argv[2]  # ex : reports/k6/screenshot.png

    # Charge le résumé
    with open(input_path, 'r') as f:
        summary = json.load(f)

    m = summary['metrics']
    # Liste des metrics qu'on veut afficher, et comment les lire
    fields = [
        ('checks',      lambda x: x.get('passes',0)/ (x.get('passes',0)+x.get('fails',0)) ),  # taux de réussite
        ('http_reqs',   lambda x: x.get('count',0)),
        ('data_received (KB)', lambda x: x.get('data',0) / 1024),
        ('data_sent (KB)',     lambda x: x.get('data',0) / 1024),
        ('iterations',  lambda x: x.get('count',0)),
        ('vus_max',     lambda x: x.get('max',0)),
    ]

    names  = []
    values = []
    for name, extractor in fields:
        if name.split()[0] in m:  # vérifie que la metric existe
            metric = m[name.split()[0]]
            val = extractor(metric)
            names.append(name)
            values.append(val)

    # Génère le bar chart
    plt.figure(figsize=(8,4))
    plt.bar(names, values)
    plt.title('K6 Summary')
    plt.ylabel('Valeur')
    plt.xticks(rotation=30, ha='right')
    plt.tight_layout()
    plt.savefig(output_path)
    print(f"Screenshot enregistré dans {output_path}")

if __name__ == '__main__':
    main()
