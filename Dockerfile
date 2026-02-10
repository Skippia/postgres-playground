###############################
# BUILD FOR LOCAL DEVELOPMENT #
###############################

FROM node:22.14-alpine AS development

WORKDIR /usr/src/app

# Copy dependencies
COPY --chown=node:node package.json pnpm-lock.yaml ./

# Install global packages
RUN npm install -g pnpm

# Install pg client
RUN apk add --no-cache postgresql-client

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy all files
# COPY --chown=node:node . .
COPY . .

# Generate prisma types
# RUN pnpm run prisma:generate

# Use the node user from the image (instead of the root user)
# Temporarily disabled due to trouble related with unlink @prisma (i guess it's my personal trouble)
# USER node

# Run application in development mode
ENTRYPOINT ["sh","./docker/entrypoint.sh"]

########################
# BUILD FOR PRODUCTION #
########################

FROM node:22.14-alpine AS build

WORKDIR /usr/src/app

COPY --chown=node:node package.json pnpm-lock.yaml ./
COPY --chown=node:node --from=development /usr/src/app/node_modules ./node_modules
COPY --chown=node:node . .

# Set NODE_ENV environment variable (it's not mandatory because we already have NODE_ENV=production in .env file)
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Install global packages
RUN npm install -g pnpm

# Build application
RUN pnpm run build

# RUN npm ci --omit=dev && npm cache clean --force
RUN pnpm install --frozen-lockfile --prod

# Temporarily disabled due to trouble related with unlink @prisma
# USER node

##############
# PRODUCTION #
##############

FROM node:22.14-alpine AS production

WORKDIR /usr/src/app

# Copy the bundled code from the build stage to the production image
COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist
COPY --chown=node:node --from=build /usr/src/app/docker ./docker

RUN chmod +x ./docker/entrypoint.sh

ENTRYPOINT ["sh","./docker/entrypoint.sh"]
