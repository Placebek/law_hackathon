import { defineStore } from 'pinia';
import axios from 'axios';

export const usePolicemanStore = defineStore('policeman', {
    state: () => ({
    }),

    actions: {
        async getPolicemanByID(policeman_id) {
            try {
              const response = await axios.get(
                `http://172.20.10.2:8000/v1/police/${policeman_id}`, 
              );
              debugger
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
        async createPoliceman(payload) {
            try {
              debugger
              const response = await axios.post(
                  `http://172.20.10.2:8000/v1/police/register`, 
                  payload
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
