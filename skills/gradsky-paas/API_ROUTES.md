# Gradsky API Routes

Base URL:

```text
https://api.gradsky.com.br
```

Header:

```text
Authorization: Bearer $GRADSKY_TOKEN
```

## Read

- `GET /account/profile`
- `GET /projects`
- `GET /projects/{projectId}`
- `GET /services`
- `GET /services?projectId={id}`
- `GET /services/{serviceId}`
- `GET /services/{serviceId}/deployments`

## Deploy

- `POST /projects/{projectId}/import-docker-app`
- `POST /projects/{projectId}/services`
- `POST /services/{serviceId}/deploy`
- `POST /services/{serviceId}/restart`
- `POST /services/{serviceId}/stop`
- `PATCH /services/{serviceId}`

## Env vars

- `GET /services/{serviceId}/env`
- `POST /services/{serviceId}/env/reveal`
- `POST /services/{serviceId}/env`
- `PATCH /services/{serviceId}/env/{key}`
- `DELETE /services/{serviceId}/env/{key}`

## Domains

- `POST /services/{serviceId}/public-domain`
- `POST /services/{serviceId}/domains`
- `POST /services/{serviceId}/domains/{domainId}/verify`
- `DELETE /domains/{domainId}`

## Domain payloads

Managed Gradsky subdomain for demos/MVPs:

```json
{
  "label": "minha-landing"
}
```

Returns a Gradsky-managed hostname like `minha-landing.gradsky.com.br`.

Custom client domain:

```json
{
  "hostname": "landing.cliente.com.br"
}
```

The custom domain starts as pending and may return DNS ownership fields such as `ownershipTxtName` and `ownershipTxtToken`.
After the user configures DNS, call:

```text
POST /services/{serviceId}/domains/{domainId}/verify
```

If DNS is still propagating, retry with backoff.

## Import Docker App

```json
{
  "composeYaml": "services:\n  app:\n    image: nginx:alpine\n    ports:\n      - \"80:80\"\n",
  "appName": "minha-landing",
  "options": {
    "autoDeploy": true,
    "continueOnError": false,
    "defaultVolumeSizeGb": 5
  }
}
```
