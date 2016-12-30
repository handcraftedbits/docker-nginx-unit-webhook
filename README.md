# NGINX Host Webhook Unit [![Docker Pulls](https://img.shields.io/docker/pulls/handcraftedbits/nginx-unit-webhook.svg?maxAge=2592000)](https://hub.docker.com/r/handcraftedbits/nginx-unit-webhook)

A [Docker](https://www.docker.com) container that provides a webhook unit for
[NGINX Host](https://github.com/handcraftedbits/docker-nginx-host).

Webhooks are useful for creating an endpoint that, when accessed, runs a command on the server hosting the webhook.
This is commonly used by REST APIs as a way to subscribe to an event.  For example, [GitHub](https://github.com)'s APIs
can call a webhook whenever a push has been made to a Git repository.

This container makes use of [adnanh/webhook](https://github.com/adnanh/webhook) to create webhooks.

# Features

* adnanh/webhook 2.6.0

# Usage

## Configuration

It is highly recommended that you use container orchestration software such as
[Docker Compose](https://www.docker.com/products/docker-compose) when using this NGINX Host unit as several Docker
containers are required for operation.  This guide will assume that you are using Docker Compose.

To begin, start with a basic `docker-compose.yml` file as described in the
[NGINX Host configuration guide](https://github.com/handcraftedbits/docker-nginx-host#configuration).  Then, add a
service for the NGINX Host webhook unit (named `webhooks`):

```yaml
webhooks:
  image: handcraftedbits/nginx-unit-webhook
  environment:
    - NGINX_UNIT_HOSTS=mysite.com
    - NGINX_URL_PREFIX=/webhooks
  volumes:
    - /home/me/webhooks.json:/opt/container/webhooks.json
  volumes_from:
    - data
```

Observe the following:

* We mount `/opt/container/webhooks.json` using the local file `/home/me/webhooks.json`.  This is a file containing our
  webhook configuration.  Refer to the [documentation](https://github.com/adnanh/webhook/blob/master/README.md) for
  information on the contents of this file.
* As with any other NGINX Host unit, we mount the volumes from our
  [NGINX Host data container](https://github.com/handcraftedbits/docker-nginx-host-data), in this case named `data`.

Finally, we need to create a link in our NGINX Host container to the `webhooks` container in order to host the
webhooks.  Here is our final `docker-compose.yml` file:

```yaml
version: '2'

services:
  data:
    image: handcraftedbits/nginx-host-data

  proxy:
    image: handcraftedbits/nginx-host
    links:
      - webhooks
    ports:
      - "443:443"
    volumes:
      - /etc/letsencrypt:/etc/letsencrypt
      - /home/me/dhparam.pem:/etc/ssl/dhparam.pem
    volumes_from:
      - data

  webhooks:
    image: handcraftedbits/nginx-unit-webhook
    environment:
      - NGINX_UNIT_HOSTS=mysite.com
      - NGINX_URL_PREFIX=/webhooks
    volumes:
      - /home/me/webhooks.json:/opt/container/webhooks.json
    volumes_from:
      - data
```

This will result in making the webhooks available at `https://mysite.com/webhooks`.

## Running the NGINX Host Webhook Unit

Assuming you are using Docker Compose, simply run `docker-compose up` in the same directory as your
`docker-compose.yml` file.  Otherwise, you will need to start each container with `docker run` or a suitable
alternative, making sure to add the appropriate environment variables and volume references.

# Reference

## Environment Variables

### `WEBHOOK_VERBOSE`

Used to show verbose webhook logging (e.g., rule matching, command execution) if set to `true`.

**Default value**: `false`

### Others

Please see the NGINX Host [documentation](https://github.com/handcraftedbits/docker-nginx-host#units) for information
on additional environment variables understood by this unit.
