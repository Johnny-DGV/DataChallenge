# DataChallenge
Proyecto para microeconometría

## Contenido del repositorio
### Bases de datos Airbnb:
1) listings (1).csv: principal base de datos para el análisis, parte de los datasets incluidos en el reto.
2) listings_scrapped.csv (no está por temas de almacenamiento): algunas variables adicionales al otro archivo de listings, destacando estimated_revenue_l365d.
3) reviews (no está por temas de almacenamiento): reseñas por listing.

### Bases de datos sobre la CDMX:
1) neighbourhoods.geojson: identificadores por municipio para ubicación geográfica de los datos.
2) estimado_ingresos.csv: Base de datos extraida del modelo experimental del INEGI. Ingreso Corriente para los Municipios de México (ICMM)
  2.1) mun_keys_ingresos.csv: Base de datos asociada para identificar claves de municipios
3) municipal Delitos - OCTUBRE 2025.xlsx: Datos mensuales por municipio para los delitos totales y por km2 en la Ciudad de México

### Codigos:
1) topic_shares: Jupyter notebook calculando shares por topic en reviews
2) mainregs.R: código procesando datasets y obteniendo modelos principales

### Archivos intermedios:
1) temas_reviews.txt: contiene lista de temas mencionados en las reseñas.
2) dicts_cats.txt: diccionarios para identificación de temas a partir de términos clave utilizados en una reseña.

## Descripción de contribución por cada miembro del equipo
Alejandro: 
  - Procesamiento de datos por alcaldías y análisis de estadística descriptiva.
  - Condensamiento de toda la información y análisis dentro del reporte.
  - Análisis de mercados para emitir recomendación de colonia.

Jose Francisco: 
  - Creación del modelo principal e interpretaciones de regresiones.
  - Obtención de datos de seguridad como variable principal en el análisis.
  - Limpieza principal de datos para regresiones.

Juan Daniel:
  - Pruebas sobre el modelo principal.
  - Obtención de datos de ingreso estimado por municipio.
  - Procesamiento de datos de texto para insights sobre temas de interés.

## Uso de la IA
### Análisis de texto
Se utilizó ChatGPT como parte integral del análisis de texto. 
Para obtener la lista extendida de temas abarcados en las reseñas, se separó la base de datos en batches que contuvieran 40 reseñas, sampleadas de tal manera que en cada batch hubiera al menos 5 listings con máximo 8 reseñas en cada uno. Este sampling fue diseñado para propiciar variabilidad dentro de cada batch. Posteriormente, se realizó un proceso iterativo de creación de la lista de temas con el chatbot de IA. Se le subía un batch y se pedía que propusiera una lista exhaustiva, pero provisional, de los temas mencionados en esa muestra. Tras la primera lista, se le subía la siguiente muestra y se le pedía que agregara temas que no hubieran aparecido antes y refinara las descripciones de los que ya habían sido propuestos. Este proceso se repitió apróximadamente 10 veces para asegurar buenos resultados, pero desde la quinta iteración los resultados tenían pocas novedades.

Una vez que decidimos la reducción de temas a 5 grupos clave, se le pidió al mismo chatbot que usara las muestras que tenía de reseñas para proponer un diccionario con términos en inglés y español que identificaran a cada grupo. Los resultados pueden observarse en los 2 archivos catalogados como intermedios en este readme.

### Programación
ChatGPT y Gemini fueron utilizados para realizar algunos procedimientos de código y resolver errores

### Reporte
Se le pidió a ChatGPT que realizara una revisión del reporte y propusiera una versión con mejor redacción y formato.
