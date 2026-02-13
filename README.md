# SSDLC RSA Encryption Service

A secure RESTful web service for RSA-based file encryption, developed following the **Secure Software Development Lifecycle (SSDLC)**.

## Features

- **Hybrid RSA + AES-256-GCM encryption** — industry-standard approach for file encryption
- **Multi-tenant architecture** with strict tenant isolation
- **JWT authentication** with role-based access control (RBAC)
- **Comprehensive audit logging** with sensitive data redaction
- **OWASP-compliant security headers** on all responses
- **Defence-in-depth** — validation at API boundary AND service layer

## Quick Start

### Prerequisites

- Python 3.11+
- pip

### Setup

```bash
# Clone and enter directory
cd ssdlc-rsa-encryption-service

# Create virtual environment
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # Linux/macOS

# Install dependencies
pip install -r requirements.txt

# Configure environment
copy .env.example .env
# Edit .env and set JWT_SECRET_KEY to a random 64-char hex string

# Run the service (development mode)
set APP_ENV=development
uvicorn src.main:app --host 0.0.0.0 --port 8443 --reload
```

### Run Tests

```bash
pytest tests/ -v --tb=short
```

### Run Security Analysis

```bash
bandit -r src/ -ll
```

## API Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/health` | Health check | No |
| POST | `/api/v1/auth/register` | Register user | No |
| POST | `/api/v1/auth/login` | Login | No |
| POST | `/api/v1/auth/refresh` | Refresh token | No |
| POST | `/api/v1/auth/logout` | Logout | Yes |
| POST | `/api/v1/files/upload` | Upload file | Yes |
| GET | `/api/v1/files/{id}` | Download file | Yes |
| POST | `/api/v1/files/{id}/encrypt` | Encrypt file | Yes |
| POST | `/api/v1/files/{id}/decrypt` | Decrypt file | Yes |
| DELETE | `/api/v1/files/{id}` | Delete file | Yes |
| POST | `/api/v1/keys/generate` | Generate RSA key pair | Yes |
| GET | `/api/v1/keys` | List keys | Yes |
| POST | `/api/v1/keys/{id}/revoke` | Revoke key | Yes |

## Documentation

See [docs/SSDLC_Report.md](docs/SSDLC_Report.md) for the complete SSDLC report covering:

1. Security Requirements Engineering
2. Threat Modeling and Risk Assessment
3. Secure Software Architecture & Design
4. Authentication & Authorization
5. Secure Implementation and Code Assurance
6. Security Testing, Validation, and Compliance
7. Secure Deployment, Operations, and Incident Response
8. Maintenance, Evolution, and Cryptographic Agility

## Architecture

```
Client → Nginx (TLS) → FastAPI → Auth (JWT/RBAC) → Crypto (RSA+AES) → Storage
```

## Security Highlights

- **RSA-OAEP** padding (PKCS#1 v1.5 prohibited — prevents padding oracle attacks)
- **AES-256-GCM** authenticated encryption (confidentiality + integrity)
- **bcrypt** password hashing (cost factor 12)
- **CSPRNG** for all random values (`os.urandom`)
- **Constant-time** hash comparisons (`hmac.compare_digest`)
- **Path traversal protection** — UUID-based filenames, resolved path validation
- **Account lockout** after 5 failed login attempts
