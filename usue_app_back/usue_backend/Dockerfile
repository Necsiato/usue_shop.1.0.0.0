FROM python:3.13-slim

ENV PYTHONPATH=/app/rats_backend
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*


RUN pip install --upgrade pip wheel "poetry>2.0.0"
RUN poetry config virtualenvs.create false

COPY pyproject.toml poetry.lock* ./
RUN poetry install --no-root

COPY . /app/rats_backend
RUN ls -la /app/rats_backend
#RUN chmod +x ./rats_backend/prestart.sh

#ENTRYPOINT ["/app/rats_backend/prestart.sh"]
CMD ["poetry", "run", "uvicorn", "rats_backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
