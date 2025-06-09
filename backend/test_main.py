import pytest
from app.main import health_check, get_message

@pytest.mark.asyncio
async def test_health_check():
    response = await health_check()
    assert response == {"status": "healthy", "message": "Backend is running successfully"}

@pytest.mark.asyncio
async def test_get_message():
    response = await get_message()
    assert response == {"message": "You've successfully integrated the backend!"} 