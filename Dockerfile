FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY . /app

# Sabse pehle git install karo
RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk git

# --- YE LINE SABSE IMPORTANT HAI ---
# Ek nakli git repo banate hain taaki startup check pass ho jaye
RUN git init && \
    git config user.email "pankaj@p.com" && \
    git config user.name "Pankaj" && \
    git add . && \
    git commit -m "fix"

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --prod --frozen-lockfile

RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

FROM base AS api
WORKDIR /app

# Build stage se saari files (.git ke saath) copy karo
COPY --from=build --chown=node:node /app /app
COPY --from=build --chown=node:node /prod/api /app

# Force Variables
ENV COBALT_SKIP_GIT_INFO=true
ENV API_URL=https://cobalt-mfur.onrender.com
ENV NODE_ENV=production

USER node

EXPOSE 9000
CMD [ "node", "src/cobalt" ]
