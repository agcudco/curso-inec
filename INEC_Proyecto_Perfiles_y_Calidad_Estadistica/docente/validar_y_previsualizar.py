"""Validación Python externa a la práctica R; genera SOLO vista previa estática."""
from pathlib import Path
from collections import Counter,defaultdict
from statistics import median, mean
from html import escape
import csv, json
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
ROOT=Path(__file__).resolve().parents[1]
with open(ROOT/'data_raw'/'encuesta_socioeconomica_2026.csv',encoding='utf-8',newline='') as f:
    df=list(csv.DictReader(f))
with open(ROOT/'data_raw'/'hogares_sinteticos_2026.csv',encoding='utf-8',newline='') as f:
    homes=list(csv.DictReader(f))
assert len(df)==2400 and len(homes)==800
assert len({x['id_encuesta'] for x in df})==2400
assert set(x['periodo_referencia'] for x in df)=={'2026-10','2026-11'}
assert Counter(x['periodo_referencia'] for x in df)=={'2026-10':1200,'2026-11':1200}
assert len(df[0])==24
valid_positive=[];zero=missing=neg=fmt=0
for x in df:
    a=x['ingreso_mensual_usd'].strip()
    if a=='NA':missing+=1;continue
    try:v=float(a)
    except ValueError:fmt+=1;continue
    if v<0:neg+=1
    elif v==0:zero+=1
    else:valid_positive.append(v)
assert zero/len(df)<.05 and missing/len(df)<.02
zonas=Counter(x['zona'] for x in df)
edus=Counter(x['nivel_educacion'] for x in df)
pov=Counter(x['pobreza_didactica'] for x in df)
orphans=sum(1 for x in df if x['id_hogar'] not in ('NA','') and x['id_hogar'] not in {h['id_hogar'] for h in homes})
# count keys repeated by same period
counts=Counter((x['periodo_referencia'],x['id_persona']) for x in df)
duprows=sum(counts[(x['periodo_referencia'],x['id_persona'])]>1 for x in df)
D=ROOT/'material_apoyo'/'figuras';D.mkdir(parents=True,exist_ok=True)

def plot_bar(counter,title,file,order=None):
    if order is None:order=[x for x,_ in counter.most_common()]
    fig,ax=plt.subplots(figsize=(8.2,4.0))
    bars=ax.bar(order,[counter[k] for k in order])
    ax.set_title(title);ax.set_ylabel('Registros')
    ax.bar_label(bars, padding=4)
    ax.tick_params(axis='x',rotation=15)
    fig.tight_layout()
    fig.savefig(D/file,dpi=155,bbox_inches='tight')
    plt.close(fig)

plot_bar(Counter({'Urbana':zonas['Urbana'],'Rural':zonas['Rural'],'Otros formatos':len(df)-zonas['Urbana']-zonas['Rural']}),
         'Zona de residencia (desbalance deliberado)','vista_zonas.png')
plot_bar(Counter({k:edus.get(k,0) for k in ['Sin instruccion','Primaria','Secundaria','Superior','Posgrado']}),
         'Educación declarada (categorías válidas literales)','vista_educacion.png',
         order=['Sin instruccion','Primaria','Secundaria','Superior','Posgrado'])
fig,ax=plt.subplots(figsize=(8.2,4))
ax.hist([min(v,3000) for v in valid_positive if v<=3000],bins=32)
ax.set_title('Ingresos personales positivos hasta 3.000 USD')
ax.set_xlabel('USD/mes');ax.set_ylabel('Registros')
fig.tight_layout();fig.savefig(D/'vista_ingresos.png',dpi=155,bbox_inches='tight');plt.close(fig)

# HTML de muestra: NO sustituye Quarto. Sin dependencias externas.
stats={'Encuestas':len(df),'Hogares':len(homes),'Zona urbana':f"{100*zonas['Urbana']/len(df):.1f}%",
       'Ingreso cero':f'{zero} ({zero/len(df)*100:.1f}%)',
       'Ingreso ausente':f'{missing} ({missing/len(df)*100:.1f}%)',
       'Edad inválida e inconsistencias': 'Inyectadas para el taller'}
blocks=''.join(f'<article><small>{escape(k)}</small><b>{escape(str(v))}</b></article>' for k,v in stats.items())
content=f'''<!doctype html><html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Vista previa — Encuesta socioeconómica sintética</title><style>
:root{{--ink:#142b40;--blue:#18658e;--bg:#f5f8fa}}body{{font-family:Arial,Helvetica,sans-serif;background:var(--bg);margin:0;color:var(--ink)}}
header{{background:#10344e;color:white;padding:44px max(24px,calc((100% - 1060px)/2))}}header h1{{margin:0 0 9px;font-size:2rem}}main{{max-width:1060px;margin:auto;padding:27px}}
.alert{{border-left:5px solid #d87426;background:white;padding:12px 19px;margin:17px 0}}.kpis{{display:grid;grid-template-columns:repeat(auto-fit,minmax(155px,1fr));gap:12px}}article{{background:white;border:1px solid #dbe4eb;border-radius:9px;padding:17px}}article small{{display:block;color:#577185;margin-bottom:12px}}article b{{font-size:1.5rem}}img{{width:100%;height:auto;max-width:900px;display:block;margin:15px auto;border:1px solid #dee8ed;border-radius:8px}}section{{margin-top:34px}}p{{line-height:1.6}}footer{{padding:30px;text-align:center;color:#527080}}</style></head>
<body><header><h1>Encuesta socioeconómica sintética 2026</h1><p>Vista previa educativa de informe · octubre y noviembre</p></header><main>
<div class="alert"><b>Solo demostración.</b> Este HTML se creó con Python para mostrar el aspecto del producto. El entregable oficial del taller debe generarse mediante <b>Quarto leyendo el RDS</b>. Los datos y el umbral son ficticios; no representan cifras del INEC.</div>
<h2>Resumen del conjunto</h2><div class="kpis">{blocks}</div>
<section><h2>1. Zonas</h2><p>La encuesta fue intencionalmente desbalanceada: predominan los registros urbanos. Los conteos no son estimadores nacionales.</p><img src="figuras/vista_zonas.png" alt="Registros por zona"></section>
<section><h2>2. Educación</h2><p>Los niveles secundario y superior predominan en la muestra sintética. Las etiquetas inválidas requieren validación.</p><img src="figuras/vista_educacion.png" alt="Registros por educación"></section>
<section><h2>3. Ingresos</h2><p>Para la mayoría de los encuestados se generaron ingresos positivos. Se introdujeron pocos ceros y faltantes y algunos formatos, negativos y extremos para auditar.</p><img src="figuras/vista_ingresos.png" alt="Histograma ingresos"></section>
<section><h2>4. Calidad e integridad</h2><p>El alumnado deberá detectar claves duplicadas, referencias de hogares ausentes, fechas incoherentes, categorías no estándar, ingresos inválidos y relaciones lógicas que requieren revisión.</p><p><strong>Ejemplos de comprobación externa:</strong> filas involucradas en duplicidad de ID persona: {duprows}; referencias a hogares no existentes: {orphans}.</p></section>
<section><h2>5. Entregables y conclusiones</h2><p>La secuencia termina con un RDS verificable, un informe HTML reproducible y un sitio web estático Quarto con metodología y resultados. La bitácora conserva propuestas, no autorizaciones.</p></section></main><footer>Práctica integrada con datos totalmente ficticios.</footer></body></html>'''
(ROOT/'material_apoyo'/'vista_previa_reporte.html').write_text(content,encoding='utf-8')
summary={'registros':len(df),'hogares':len(homes),'columnas':len(df[0]),'urbana':zonas['Urbana'],
         'rural':zonas['Rural'],'ceros':zero,'ausentes_ingresos':missing,'negativos':neg,
         'formatos_ingresos_invalidos':fmt,'dup_filas':duprows,'referencias_hogar_huerfanas':orphans,
         'pobreza_didactica':dict(pov),'educacion':dict(edus)}
(ROOT/'docente'/'validacion_dataset.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(summary,ensure_ascii=False,indent=2))
