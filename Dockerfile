FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY . /app
RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk git

FROM base AS api
WORKDIR /app
# Final stage mein git install karna zaroori hai
RUN apk add --no-cache git

# Stage build se files copy karo
COPY --from=build --chown=node:node /prod/api /app

# --- START FIX: dummy git setup to stop "could not parse remote" ---
RUN git init && \
    git remote add origin https://github.com/imputnet/cobalt.git && \
    git config user.email "p@p.com" && \
    git config user.name "Pankaj" && \
    git add . && \
    git commit -m "fix"
# --- END FIX ---

# Force variables
ENV COBALT_SKIP_GIT_INFO=true
ENV API_URL=https://cobalt-mfur.onrender.com
ENV NODE_ENV=production

USER node
EXPOSE 9000
CMD [ "node", "src/cobalt" ]
