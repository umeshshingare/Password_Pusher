#!/bin/bash
set -e

export RAILS_ENV=production

echo ""
if [ -z "$DATABASE_URL" ]
then
    echo "DATABASE_URL not specified. Assuming ephemeral backend. Database may be lost on container restart."
    echo "To set a database backend refer to https://docs.pwpush.com/docs/how-to-universal/#how-does-it-work"
    export DATABASE_URL=sqlite3:db/db.sqlite3
else
    echo "According to DATABASE_URL database backend is set to $(echo $DATABASE_URL|cut -d ":" -f 1):..."
fi
echo ""

echo "Password Pusher: migrating database to latest..."
bundle exec rake db:migrate

if [ -n "$PWP__THEME" ] || [ -n "$PWP_PRECOMPILE" ]; then
    echo "Password Pusher: precompiling assets for customizations..."
    bundle exec rails assets:precompile
fi

# Set the default port if not specified
if [ -n "$PORT" ]; then
    export TARGET_PORT=$PORT
else
    export TARGET_PORT=5100
fi

echo "Password Pusher: starting foreman..."
if [ -n "$PWP__NO_WORKER" ] || [ -n "$PWP_PUBLIC_GATEWAY" ]; then
    exec bundle exec foreman start -m web=1
else
    exec bundle exec foreman start -m web=1,worker=1
fi
