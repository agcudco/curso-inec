"""Datos 100% sintéticos para prácticas académicas. No estadística oficial."""
from pathlib import Path
import csv, random, math, statistics, collections, json, datetime
ROOT=Path(__file__).resolve().parents[1]
R=random.Random(426112)
provs=[('Pichincha',.37),('Guayas',.29),('Azuay',.15),('Cotopaxi',.10),('Manabi',.09)]
edus=['Sin instruccion','Primaria','Secundaria','Superior','Posgrado']

def choice(pairs):
    vals,weights=zip(*pairs)
    return R.choices(vals,weights=weights,k=1)[0]

def money(x): return f'{x:.2f}'

def split_positive(total,n):
    vals=[R.gammavariate(2.0,1.0) for _ in range(n)]
    tot=sum(vals)
    xs=[round(total*v/tot,2) for v in vals]
    xs[-1]=round(total-sum(xs[:-1]),2)
    return xs

persons=[]; hogares=[]
for period in ('2026-10','2026-11'):
    households=[]; members={i:1 for i in range(400)}
    for _ in range(800):
        candidates=[i for i in range(400) if members[i]<7]
        idx=R.choice(candidates)
        members[idx]+=1
    for hi in range(400):
        hid=f'H{period.replace("-","")}{hi+1:04d}'
        zona=choice([('Urbana',.79),('Rural',.21)])
        province=choice(provs)
        num=members[hi]
        prob_poor=.28 if zona=='Rural' else .19
        poor=R.random()<prob_poor
        bracket=choice([('bajo',.36),('medio',.56),('alto',.08)]) if not poor else 'pobre'
        if bracket=='pobre': pc=R.uniform(72,179)
        elif bracket=='bajo': pc=R.uniform(190,300)
        elif bracket=='medio': pc=R.uniform(300,730)
        else: pc=R.uniform(740,1950)
        total=round(pc*num,2)
        dist=split_positive(total,num)
        # Bajar a 0 solo una fracción pequeña; redistribuir a los otros integrantes
        for j in range(num):
            if R.random()<.018 and num>1:
                shift=dist[j]; dist[j]=0.0
                k=(j+1)%num; dist[k]=round(dist[k]+shift,2)
        assert round(sum(dist),2)==round(total,2)
        hogar={'id_hogar':hid,'periodo_referencia':period,'provincia':province,'zona':zona,
               'miembros_hogar':str(num),'ingreso_hogar_mensual_usd':money(total),
               'ingreso_per_capita_usd':money(total/num),
               'pobreza_didactica':('Pobre' if total/num<185 else 'No pobre'),
               'tipo_vivienda':choice([('Casa',.65),('Departamento',.24),('Cuarto',.11)]),
               'acceso_agua':choice([('Si',.91),('No',.09)]),
               'acceso_saneamiento':choice([('Si',.86),('No',.14)])}
        hogares.append(hogar)
        for j in range(num):
            idp=f'P{period.replace("-","")}{len(persons)+1:05d}'
            age=choice([(R.randint(18,35),.72),(R.randint(36,59),.23),(R.randint(60,79),.05)])
            edu=choice([('Sin instruccion',.025),('Primaria',.13),('Secundaria',.48),('Superior',.32),('Posgrado',.045)])
            schooling={'Sin instruccion':0,'Primaria':6,'Secundaria':12,'Superior':16,'Posgrado':19}[edu]
            schooling=max(0,schooling+R.choice([-1,0,0,0,0,1]))
            active=choice([('Ocupado',.74),('Desocupado',.10),('Inactivo',.16)])
            hours= str(R.randint(18,55) if active=='Ocupado' else 0)
            day=R.randint(1,28)
            tipo_ing=choice([('Trabajo',.76),('Comercio',.10),('Transferencia',.08),('Otros',.06)])
            persons.append({'id_encuesta':f'E{period.replace("-","")}{len(persons)+1:05d}',
               'id_persona':idp,'id_hogar':hid,'periodo_referencia':period,
               'fecha_entrevista':f'{period}-{day:02d}','provincia':province,'zona':zona,
               'edad':str(age),'sexo':choice([('Mujer',.52),('Hombre',.48)]),
               'nivel_educacion':edu,'anios_escolaridad':str(schooling),
               'condicion_actividad':active,'horas_trabajo_semana':hours,
               'ingreso_mensual_usd':money(dist[j]),'fuente_ingreso':tipo_ing,
               'acceso_internet':choice([('Si',.83),('No',.17)]),
               'acceso_computador':choice([('Si',.62),('No',.38)]),
               'tipo_vivienda':hogar['tipo_vivienda'],
               'miembros_hogar':str(num),
               'ingreso_hogar_mensual_usd':money(total),
               'ingreso_per_capita_usd':money(total/num),
               'pobreza_didactica':hogar['pobreza_didactica'],
               'acceso_agua':hogar['acceso_agua'],
               'acceso_saneamiento':hogar['acceso_saneamiento']})

assert len(persons)==2400 and len(hogares)==800
# Set de anomalías no superpuestos en lo posible y listado para instructor
anomalies=[]
used=collections.defaultdict(set)
def sample_idx(period=None,n=1,avoid=None):
    subset=[i for i,p in enumerate(persons) if (period is None or p['periodo_referencia']==period)
            and i not in used[avoid or 'global']]
    ids=R.sample(subset,n)
    used[avoid or 'global'].update(ids)
    return ids

def set_anom(column, values, code):
    idxs=sample_idx(n=len(values))
    for i,val in zip(idxs,values):
        old=persons[i][column]
        persons[i][column]=val
        anomalies.append({'regla':code,'id_encuesta':persons[i]['id_encuesta'],'columna':column,'original':old,'modificado':val})

# 1.8% ausencias explícitas, 1.4% cero (ya ~1.8% ceros de generación)
set_anom('ingreso_mensual_usd',['NA']*24,'AUS_INGRESO')
set_anom('edad',['NA']*12,'AUS_EDAD')
set_anom('nivel_educacion',['NA']*10,'AUS_EDUCACION')
set_anom('ingreso_mensual_usd',['-125.00']*7,'ING_NEGATIVO')
set_anom('ingreso_mensual_usd',['950,50']*5+['USD 410']*3,'ING_FORMATO')
set_anom('edad',['-2','120','tres','-6','135','diecinueve'],'EDAD_INVALIDA')
set_anom('nivel_educacion',['99']*8+['Secundaria ']*5+['SUPERIOR']*5,'EDUCACION_DOMINIO_FORMATO')
set_anom('provincia',['PICHINCHA']*5+['Sin provincia']*5+['Guayas ']*5,'PROVINCIA_FORMATO_DOMINIO')
set_anom('zona',['URBANA']*4+['Rural ']*4+['99']*3,'ZONA_FORMATO_DOMINIO')
set_anom('id_hogar',['H9999999999']*10,'HOGAR_HUERFANO')
set_anom('id_hogar',['NA']*5,'HOGAR_FALTANTE')
set_anom('fecha_entrevista',['2026-11-31']*6+['2026-12-04']*6,'FECHA_INVALIDA_FUERA_PERIODO')
# Ocupados con cero horas / No ocupados con horas positivas
cond_candidates=[i for i,p in enumerate(persons) if p['condicion_actividad']=='Ocupado' and p['horas_trabajo_semana']!='0']
for i in R.sample(cond_candidates,12):
    old=persons[i]['horas_trabajo_semana'];persons[i]['horas_trabajo_semana']='0'
    anomalies.append({'regla':'TRABAJO_OCUPADO_CERO','id_encuesta':persons[i]['id_encuesta'],'columna':'horas_trabajo_semana','original':old,'modificado':'0'})
cond_candidates=[i for i,p in enumerate(persons) if p['condicion_actividad'] in ('Inactivo','Desocupado') and p['horas_trabajo_semana']=='0']
for i in R.sample(cond_candidates,14):
    old=persons[i]['horas_trabajo_semana'];persons[i]['horas_trabajo_semana']='35'
    anomalies.append({'regla':'TRABAJO_NO_OCUPADO_HORAS','id_encuesta':persons[i]['id_encuesta'],'columna':'horas_trabajo_semana','original':old,'modificado':'35'})
# Duplicaciones deliberadas: id_encuesta sigue identificando inequívocamente la fila
by_period=collections.defaultdict(list)
for i,p in enumerate(persons):by_period[p['periodo_referencia']].append(i)
for period in by_period:
    ids=R.sample(by_period[period],18)
    for i,j in zip(ids[:9],ids[9:]):
        # Conservamos un id_encuesta único, pero la clave id_persona duplica
        old=persons[j]['id_persona']; persons[j]['id_persona']=persons[i]['id_persona']
        anomalies.append({'regla':'ID_PERSONA_DUPLICADO','id_encuesta':persons[j]['id_encuesta'],'columna':'id_persona','original':old,'modificado':persons[j]['id_persona']})
# contradicciones deliberadas en características replicadas del hogar
set_anom('pobreza_didactica',['Pobre']*6+['No pobre']*6,'POBREZA_ETIQUETA_INCOHERENTE')
set_anom('miembros_hogar',['12']*9,'TAMANIO_HOGAR_INCOHERENTE')
set_anom('ingreso_per_capita_usd',['100.00']*7,'INGRESO_PC_INCOHERENTE')
# Intro: pesos desbalanceados pero un solo marco, no inferencia
headers=list(persons[0])
hheaders=list(hogares[0])
def write(path,rows,fields):
    path.parent.mkdir(parents=True,exist_ok=True)
    with path.open('w',encoding='utf-8',newline='') as f:
        writer=csv.DictWriter(f,fieldnames=fields);writer.writeheader();writer.writerows(rows)
write(ROOT/'data_raw'/'encuesta_socioeconomica_2026.csv',persons,headers)
write(ROOT/'data_raw'/'hogares_sinteticos_2026.csv',hogares,hheaders)
for period in ('2026-10','2026-11'):
    write(ROOT/'data_raw'/f'encuesta_socioeconomica_{period.replace("-", "_")}.csv',
        [p for p in persons if p['periodo_referencia']==period],headers)
write(ROOT/'docente'/'inventario_anomalias.csv',anomalies,list(anomalies[0]))
provs_validas=[{'provincia':x} for x,_ in provs]
write(ROOT/'diccionario'/'catalogo_provincias.csv',provs_validas,['provincia'])
write(ROOT/'diccionario'/'catalogo_educacion.csv',[{'nivel_educacion':x} for x in edus],['nivel_educacion'])
rows=[]
desc={
 'id_encuesta':('texto','Identificador único del formulario; no confundir con persona','único y presente'),
 'id_persona':('texto','Identificador individual sintético','único dentro de período'),
 'id_hogar':('texto','Clave de vinculación con tabla hogares','presente y referenciada'),
 'periodo_referencia':('texto','Mes de la encuesta','YYYY-MM'),
 'fecha_entrevista':('texto','Fecha de registro','YYYY-MM-DD'),
 'provincia':('texto','Provincia del hogar','catálogo didáctico'),
 'zona':('texto','Zona de residencia','Urbana/Rural'),
 'edad':('entero','Edad en años cumplidos','18–110 para el ejercicio'),
 'sexo':('texto','Sexo declarado (categoría didáctica)','Mujer/Hombre'),
 'nivel_educacion':('texto','Máximo nivel educativo declarado','catálogo didáctico'),
 'anios_escolaridad':('entero','Años de educación completados','0–25'),
 'condicion_actividad':('texto','Situación declarada de actividad','Ocupado/Desocupado/Inactivo'),
 'horas_trabajo_semana':('entero','Horas trabajadas en semana de referencia','0–80'),
 'ingreso_mensual_usd':('decimal','Ingreso total personal mensual sintético','USD y punto decimal; ≥0'),
 'fuente_ingreso':('texto','Fuente principal declarada','Trabajo/Comercio/Transferencia/Otros'),
 'acceso_internet':('texto','Acceso declarado a Internet','Si/No'),
 'acceso_computador':('texto','Acceso declarado a computador','Si/No'),
 'tipo_vivienda':('texto','Tipo de vivienda del hogar','Casa/Departamento/Cuarto'),
 'miembros_hogar':('entero','Tamaño del hogar registrado','≥1; coherencia entre archivos'),
 'ingreso_hogar_mensual_usd':('decimal','Ingreso agregado del hogar','USD; derivado sintético'),
 'ingreso_per_capita_usd':('decimal','Ingreso hogar / número de miembros','USD/mes/persona'),
 'pobreza_didactica':('texto','Clasificación del umbral educativo USD 185','Pobre/No pobre'),
 'acceso_agua':('texto','Acceso declarado a agua','Si/No'),
 'acceso_saneamiento':('texto','Acceso declarado a saneamiento','Si/No'),
}
for col in headers:
    t,d,rule=desc[col]
    rows.append({'variable':col,'tipo_esperado':t,'definicion':d,'control_didactico':rule})
write(ROOT/'diccionario'/'diccionario_variables.csv',rows,['variable','tipo_esperado','definicion','control_didactico'])
meta={'datos':'SINTETICOS / NO INEC','semilla':426112,'filas_personas':len(persons),'filas_hogares':len(hogares),
 'periodos':['2026-10','2026-11'],'umbral_pobreza_ficticio_usd_por_persona_mes':185,
 'definicion':'pobreza_didactica= Pobre si ingreso_hogar_mensual_usd/miembros_hogar <185; No pobre en caso contrario. No es indicador oficial.',
 'anotacion':'Muestra desbalanceada deliberadamente: no representativa ni comparable causalmente. Incoherencias incluidas para el taller.'}
(ROOT/'diccionario'/'metadatos.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding='utf-8')
C=collections.Counter
numbers=C()
for p in persons:
    numbers['zona_'+p['zona']]+=1
    numbers['educacion_'+p['nivel_educacion']]+=1
    numbers['pobreza_'+p['pobreza_didactica']]+=1
    if p['ingreso_mensual_usd']=='NA':numbers['ingreso_NA']+=1
    else:
        try:
            f=float(p['ingreso_mensual_usd'])
            if f==0:numbers['ingreso_cero']+=1
            if f<0:numbers['ingreso_negativo']+=1
        except ValueError:numbers['ingreso_formato_invalido']+=1
print('GENERADO',meta,'COLUMNAS',len(headers),'ANOMALIAS',len(anomalies))
print('DISTRIBUCIONES',numbers)
(ROOT/'docente'/'resumen_generacion.json').write_text(json.dumps({'meta':meta,'conteos':numbers,'anomalias_inyectadas':len(anomalies)},ensure_ascii=False,indent=2),encoding='utf-8')
