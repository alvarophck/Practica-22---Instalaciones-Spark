# Imagen unica para el master, los workers y JupyterLab:
# asi todos los contenedores tienen exactamente la misma version de Spark, Java y Python.
FROM spark:4.1.4-scala2.13-java17-python3-ubuntu

USER root

ARG SPARK_VERSION=4.1.4
ARG SCALA_VERSION=2.13.17
ARG ALMOND_VERSION=0.14.5

ENV HOME=/home/spark \
    COURSIER_CACHE=/opt/coursier/cache \
    PYSPARK_PYTHON=python3 \
    PYSPARK_DRIVER_PYTHON=python3 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    PIP_NO_CACHE_DIR=1

# 1. Utilidades del sistema
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates python3-pip \
 && rm -rf /var/lib/apt/lists/*

# 2. Comprobar que la version de Scala de Spark es la esperada por el kernel de Scala
RUN test -f /opt/spark/jars/scala-library-${SCALA_VERSION}.jar \
 || (echo "ERROR: esta imagen de Spark no usa Scala ${SCALA_VERSION}. Version encontrada:" \
     && ls /opt/spark/jars/scala-library-*.jar && exit 1)

# 3. PySpark: se usa el que viene con Spark (misma version exacta que el cluster)
RUN SITE=$(python3 -c "import site; print(site.getsitepackages()[0])") \
 && PY4J=$(ls /opt/spark/python/lib/py4j-*-src.zip) \
 && printf "/opt/spark/python\n%s\n" "$PY4J" > "$SITE/pyspark_spark_home.pth" \
 && python3 -c "import pyspark; print('PySpark', pyspark.__version__)"

# 4. JupyterLab y librerias de Python habituales
RUN python3 -m pip install "jupyterlab>=4,<5" ipykernel "pandas>=2.2,<3" "pyarrow>=15" \
 && jupyter --version

# 5. Kernel de Scala (Almond) para la misma version de Scala que usa Spark,
#    y descarga anticipada de las librerias de Spark para Scala
RUN mkdir -p /opt/coursier \
 && curl -fL -o /opt/coursier/coursier https://github.com/coursier/launchers/raw/master/coursier \
 && chmod +x /opt/coursier/coursier \
 && /opt/coursier/coursier launch --use-bootstrap "almond:${ALMOND_VERSION}" --scala "${SCALA_VERSION}" -- \
      --install --global --id scala --display-name "Scala ${SCALA_VERSION} (Spark ${SPARK_VERSION})" \
 && /opt/coursier/coursier fetch "org.apache.spark:spark-sql_2.13:${SPARK_VERSION}" > /dev/null \
 && chmod -R a+rwX /opt/coursier

# 6. Logs de Spark menos verbosos (nivel WARN): se crea el fichero, la imagen no trae plantilla
RUN mkdir -p /opt/spark/conf \
 && printf '%s\n' \
    'rootLogger.level = warn' \
    'rootLogger.appenderRef.stdout.ref = console' \
    'appender.console.type = Console' \
    'appender.console.name = console' \
    'appender.console.target = SYSTEM_ERR' \
    'appender.console.layout.type = PatternLayout' \
    'appender.console.layout.pattern = %d{yy/MM/dd HH:mm:ss} %p %c{1}: %m%n%ex' \
    > /opt/spark/conf/log4j2.properties

# 7. Carpetas de trabajo con permisos para el usuario spark
RUN mkdir -p /home/spark/notebooks /opt/datos /opt/metastore \
 && chown -R spark:spark /home/spark /opt/datos /opt/metastore

USER spark
WORKDIR /home/spark
