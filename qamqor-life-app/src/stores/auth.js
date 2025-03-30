import { defineStore } from 'pinia';
import { saveToken, getToken, removeToken } from '../utils/auth';
import axios from 'axios';


export const useAuthStore = defineStore('auth', {
    state: () => ({
    }),

    actions: {
      async login(username, password) {
        this.error = null;

        try {
          const response = await axios.post(
              'http://172.20.10.2:8000/v1/admin/login_admin',
              {
                username: username,
                password: password 
              }
          );
          return response.data;

        } catch (error) {
          if (error.response) {
              this.error = error.response.data.message || 'Ошибка при авторизации';
          } else {
              this.error = 'Произошла ошибка, повторите позднее';
          }
          return { success: false, error: this.error };
        }
      },
    },

    persist: true, 
});
