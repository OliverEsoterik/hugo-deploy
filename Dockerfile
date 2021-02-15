FROM nginx:alpine as build

RUN apk add --update \
    wget
    
ARG HUGO_VERSION="0.72.0"
RUN wget --quiet "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz" && \
    tar xzf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    rm -r hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    mv hugo /usr/bin

COPY ./ /go/bin/hugo
WORKDIR /go/bin/hugo


#Copy static files to Nginx
FROM nginx:alpine

COPY --from=build /go/bin/hugo /usr/share/nginx/html

WORKDIR /usr/share/nginx/html

# libc6-compat & libstdc++ are required for extended SASS libraries
# ca-certificates are required to fetch outside resources
RUN apk update && \
    apk add --no-cache ca-certificates libc6-compat libstdc++ git

# Expose port for live server
EXPOSE 1313

ENTRYPOINT ["hugo"]
CMD ["server", "--theme", "book"]
