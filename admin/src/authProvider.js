import { AUTH_LOGIN, AUTH_LOGOUT, AUTH_ERROR, AUTH_CHECK, AUTH_GET_PERMISSIONS } from 'react-admin';
import jwt_decode from 'jwt-decode';

// Change this to be your own login check route.

let reflectedEntrypoint = false;
if (window.location.host === "staging-admin.ryzencontroller.com") {
  reflectedEntrypoint = "https://staging-api.ryzencontroller.com";
}
if (window.location.host === "admin.ryzencontroller.com") {
  reflectedEntrypoint = "https://api.ryzencontroller.com";
}
const entrypoint = reflectedEntrypoint ? reflectedEntrypoint : process.env.REACT_APP_API_ENTRYPOINT;
const login_uri = entrypoint + '/authentication_token';

export default (type, params) => {
    switch (type) {
        case AUTH_LOGIN:
            const {username, password} = params;
            const request = new Request(`${login_uri}`, {
                method: 'POST',
                body: JSON.stringify({username, password}),
                headers: new Headers({'Content-Type': 'application/json'}),
            });

            return fetch(request)
                .then(response => {
                    if (response.status < 200 || response.status >= 300) throw new Error(response.statusText);

                    return response.json();
                })
                .then(({token}) => {
                    localStorage.setItem('token', token); // The JWT token is stored in the browser's local storage
                    const decodedToken = jwt_decode(token);
                    localStorage.setItem('role', decodedToken.roles); // The Role is stored in the browser's local storage
                    window.location.replace('/');
                });

        case AUTH_LOGOUT:
            localStorage.removeItem('token');
            localStorage.removeItem('role');
            return Promise.resolve();

        case AUTH_ERROR:
            if (401 === params.status || 403 === params.status) {
                localStorage.removeItem('token');

                return Promise.reject();
            }
            break;

        case AUTH_CHECK:
            return localStorage.getItem('token') ? Promise.resolve() : Promise.reject();

        case AUTH_GET_PERMISSIONS:
            return localStorage.getItem('role') ? Promise.resolve() : Promise.reject();

        default:
            return Promise.reject();
    }
}
