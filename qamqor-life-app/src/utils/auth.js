export function isLoggedIn() {
    const token = localStorage.getItem('access_token');
    return token !== null && token !== '';
}

export function saveToken(token) {
    if (token) {
        localStorage.setItem('access_token', token);
    }
}

export function getToken() {
    return localStorage.getItem('access_token');
}

export function removeToken() {
    localStorage.removeItem('access_token');
}
