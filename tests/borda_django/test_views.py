import pytest
from django.urls import reverse


@pytest.mark.django_db
def test_pagina_inicio_retorna_200(client):
    url = reverse('inicio')
    response = client.get(url)
    assert response.status_code == 200
