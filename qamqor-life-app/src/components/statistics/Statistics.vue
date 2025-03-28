<template>
  <div class="bg-custom-gradient h-full flex justify-start">
    <Navbar />
    <div class="w-full h-full pt-8 pl-8 pr-8">
      <div class="w-full bg-white rounded-t-[25px] p-8 text-black ">
        <div class="text-[#6388A8] text-[18px] pl-5">
          < Назад
        </div>
        <div>
          Day: {{ formattedDate }}
        </div>
        
        <div class="pt-16 mx-24">
          <div class="grid grid-cols-6 gap-6">
            <div></div>
            <div>full name</div>
            <div>genre</div>
            <div>time</div>
            <div>application time</div>
            <div>raised matter</div>
          </div>
        </div>

        <div class="pt-3">
          <div class="w-[95%] h-[1px] bg-gray-300 mx-auto my-4"></div>
        </div>

        <div class="pt-10 mx-24">
          <div class="grid grid-cols-6 gap-6">
            <div class="w-[100px] h-[35px] bg-[#6388A8] rounded-[5px]"></div>
            <div>Серік Диляра</div>
            <div>Ж</div>
            <div>23:25:04</div>
            <div>23:25:04</div>
            <div>AC326023</div>
          </div>
        </div>
        <div class="pt-10 mx-24">
          <div class="grid grid-cols-6 gap-6">
            <div class="w-[100px] h-[35px] bg-[#6388A8] rounded-[5px]"></div>
            <div>Серік Диляра</div>
            <div>Ж</div>
            <div>23:25:04</div>
            <div>23:25:04</div>
            <div>AC326023</div>
          </div>
        </div>
        <div class="pt-10 mx-24">
          <div class="grid grid-cols-6 gap-6">
            <div class="w-[100px] h-[35px] bg-[#6388A8] rounded-[5px]"></div>
            <div>Серік Диляра</div>
            <div>Ж</div>
            <div>23:25:04</div>
            <div>23:25:04</div>
            <div>AC326023</div>
          </div>
        </div>
        <div class="pt-10 mx-24">
          <div class="grid grid-cols-6 gap-6">
            <div class="w-[100px] h-[35px] bg-[#6388A8] rounded-[5px]"></div>
            <div>Серік Диляра</div>
            <div>Ж</div>
            <div>23:25:04</div>
            <div>23:25:04</div>
            <div>AC326023</div>
          </div>
        </div>
        <div class="pt-10 mx-24">
          <div class="grid grid-cols-6 gap-6">
            <div class="w-[100px] h-[35px] bg-[#6388A8] rounded-[5px]"></div>
            <div>Серік Диляра</div>
            <div>Ж</div>
            <div>23:25:04</div>
            <div>23:25:04</div>
            <div>AC326023</div>
          </div>
        </div>
        <div class="pt-10 mx-24">
          <div class="grid grid-cols-6 gap-6">
            <div class="w-[100px] h-[35px] bg-[#6388A8] rounded-[5px]"></div>
            <div>Серік Диляра</div>
            <div>Ж</div>
            <div>23:25:04</div>
            <div>23:25:04</div>
            <div>AC326023</div>
          </div>
        </div>
        <div class="pt-10 mx-24">
          <div class="grid grid-cols-6 gap-6">
            <div class="w-[100px] h-[35px] bg-[#6388A8] rounded-[5px]"></div>
            <div>Серік Диляра</div>
            <div>Ж</div>
            <div>23:25:04</div>
            <div>23:25:04</div>
            <div>AC326023</div>
          </div>
        </div>
        <div class="pt-10 mx-24">
          <div class="grid grid-cols-6 gap-6">
            <div class="w-[100px] h-[35px] bg-[#6388A8] rounded-[5px]"></div>
            <div>Серік Диляра</div>
            <div>Ж</div>
            <div>23:25:04</div>
            <div>23:25:04</div>
            <div>AC326023</div>
          </div>
        </div>


      </div>

    </div>
  </div>
</template>


<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { OhVueIcon, addIcons } from "oh-vue-icons";
import { IoSearch } from "oh-vue-icons/icons";
import Navbar from "../menu/Navbar.vue";

addIcons(IoSearch);

const route = useRoute();
const rawDate = route.query.date;
const selectedDate = ref(rawDate ? new Date(rawDate) : new Date());

const formattedDate = computed(() =>
  selectedDate.value.toLocaleDateString('ru-RU', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  })
);
</script>