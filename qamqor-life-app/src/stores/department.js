import { defineStore } from 'pinia';
import { saveToken, getToken, removeToken } from '../utils/auth';
import axios from 'axios';


export const useDepartmentStore = defineStore('department', {
    state: () => ({
    }),

    actions: {
      async allDepartments() {
        this.error = null;

        try {
          const response = await axios.get(
              'http://127.0.0.1:8000/v1/all_stations',
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
      async getDepartmentByID(department_id) {
        try {
          const response = await axios.get(
              `http://127.0.0.1:8000/v1/by-station-id/${department_id}`, 
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
      async updateStatement(statement_id, policeman_id) {
        try {
          const response = await axios.put(
            `http://127.0.0.1:8000/v1/statement-update/${statement_id}`,
            { policeman_id }
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
