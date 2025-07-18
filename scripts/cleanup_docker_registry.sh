#!/bin/bash

REGISTRY="localhost:5000"
THRESHOLD_DAYS=90

# ISO date comparison threshold
CUTOFF_DATE=$(date -d "$THRESHOLD_DAYS days ago" --iso-8601=seconds)

REPOS=$(curl -s http://$REGISTRY/v2/_catalog | jq -r '.repositories[]')

for REPO in $REPOS; do
  TAGS=$(curl -s http://$REGISTRY/v2/$REPO/tags/list | jq -r '.tags[]?')

  for TAG in $TAGS; do
    # Get manifest (v2 schema)
    MANIFEST=$(curl -s -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
      http://$REGISTRY/v2/$REPO/manifests/$TAG)

    # Get config digest from manifest
    CONFIG_DIGEST=$(echo "$MANIFEST" | jq -r '.config.digest')

    # Get config blob (contains created date)
    CONFIG=$(curl -s http://$REGISTRY/v2/$REPO/blobs/$CONFIG_DIGEST)
    CREATED=$(echo "$CONFIG" | jq -r '.created')

    if [[ "$CREATED" < "$CUTOFF_DATE" ]]; then
      echo "🗑️ Deleting $REPO:$TAG created at $CREATED"

      # Get manifest digest for deletion
      DIGEST=$(curl -sI -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
        http://$REGISTRY/v2/$REPO/manifests/$TAG \
        | grep Docker-Content-Digest | awk '{print $2}' | tr -d $'\r')

      # Delete manifest
      curl -X DELETE http://$REGISTRY/v2/$REPO/manifests/$DIGEST
    else
      echo "✅ Keeping $REPO:$TAG created at $CREATED"
    fi
  done
done

docker exec -it docker-registry registry garbage-collect /etc/docker/registry/config.yml --delete-untagged=true