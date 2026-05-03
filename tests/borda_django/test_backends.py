import pytest
from django.contrib.auth import get_user_model

from apps_django.contas.backends import EmailBackend

User = get_user_model()


@pytest.fixture
def usuario(db):
    return User.objects.create_user(email='teste@exemplo.com', password='senha123', first_name='Teste', last_name='Exemplo')


def test_autentica_com_email_e_senha_corretos(usuario):
    backend = EmailBackend()
    user = backend.authenticate(None, username='teste@exemplo.com', password='senha123')
    assert user is not None
    assert user.email == 'teste@exemplo.com'


@pytest.mark.django_db
def test_autentica_com_email_inexistente():
    backend = EmailBackend()
    user = backend.authenticate(None, username='inexistente@exemplo.com', password='senha123')
    assert user is None


@pytest.mark.django_db
def test_autentica_com_senha_incorreta(usuario):
    backend = EmailBackend()
    user = backend.authenticate(None, username='teste@exemplo.com', password='senhaerrada')
    assert user is None
