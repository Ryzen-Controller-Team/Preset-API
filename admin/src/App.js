import React from "react";
import { Redirect, Route } from "react-router-dom";
import {
  HydraAdmin,
  hydraDataProvider as baseHydraDataProvider,
  fetchHydra as baseFetchHydra
} from "@api-platform/admin";
import parseHydraDocumentation from "@api-platform/api-doc-parser/lib/hydra/parseHydraDocumentation";
import authProvider from "./authProvider.js";

const entrypoint = process.env.REACT_APP_API_ENTRYPOINT;
const fetchHeaders = {
  Authorization: `Bearer ${window.localStorage.getItem("token")}`
};
const fetchHydra = (url, options = {}) =>
  baseFetchHydra(url, {
    ...options,
    headers: new Headers(fetchHeaders)
  });
const apiDocumentationParser = entrypoint =>
  parseHydraDocumentation(entrypoint, {
    headers: new Headers(fetchHeaders)
  }).then(
    ({ api }) => ({ api }),
    result => {
      const { api, status } = result;

      if (status === 401) {
        return Promise.resolve({
          api,
          status,
          customRoutes: [
            <Route path="/" render={() => <Redirect to="/login" />} />
          ]
        });
      }

      return Promise.reject(result);
    }
  );
const dataProvider = baseHydraDataProvider(
  entrypoint,
  fetchHydra,
  apiDocumentationParser
);

export default () => (
  <HydraAdmin
    apiDocumentationParser={apiDocumentationParser}
    dataProvider={dataProvider}
    authProvider={authProvider}
    entrypoint={entrypoint}
  />
);
