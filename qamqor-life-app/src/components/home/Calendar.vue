<template>
  <div class="p-4 bg-white text-black rounded-[25px] shadow-lg" style="box-shadow: 0 4px 10px #6388A8">
    <div class="flex justify-between items-center mb-4">
      <button @click="prevMonth">←</button>
      <div>
        <div>{{ currentMonthName }} {{ currentYear }}</div>
        <span class="text-sm text-gray-500">{{ formattedDate }}</span>
      </div>
      <button @click="nextMonth">→</button>
    </div>

    <div class="grid grid-cols-7 gap-1 text-center mb-2 font-semibold">
      <div v-for="day in daysOfWeek" :key="day">{{ day }}</div>
    </div>

    <div class="grid grid-cols-7 gap-1 text-center">
      <div v-for="n in blankDays" :key="'b' + n">&nbsp;</div>
      <div
        v-for="day in daysInMonth"
        :key="day"
        @click="selectDate(day)"
        :class="[
          'cursor-pointer p-2 rounded-full',
          isSelected(day) ? 'bg-[#6388A8] text-white' : 'hover:bg-[#BED2E3]'
        ]"
      >
        {{ day }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed } from "vue";

const props = defineProps({
  modelValue: Date,
});
const emit = defineEmits(["update:modelValue"]);

const localDate = ref(new Date(props.modelValue || new Date()));

watch(
  () => props.modelValue,
  (val) => {
    if (val) localDate.value = new Date(val);
  }
);

const currentYear = computed(() => localDate.value.getFullYear());
const currentMonth = computed(() => localDate.value.getMonth());
const currentMonthName = computed(() =>
  localDate.value.toLocaleString("default", { month: "long" })
);

const formattedDate = computed(() => {
  return localDate.value.toLocaleDateString("en-US", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });
});

const daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"];

const daysInMonth = computed(() => {
  const days = new Date(currentYear.value, currentMonth.value + 1, 0).getDate();
  return Array.from({ length: days }, (_, i) => i + 1);
});

const blankDays = computed(() => {
  const firstDay = new Date(currentYear.value, currentMonth.value, 1).getDay();
  return firstDay;
});

function selectDate(day) {
  const selected = new Date(currentYear.value, currentMonth.value, day);
  emit("update:modelValue", selected);
  localDate.value = selected;
}

function isSelected(day) {
  if (!props.modelValue) return false;
  const selected = new Date(props.modelValue);
  return (
    selected.getDate() === day &&
    selected.getMonth() === currentMonth.value &&
    selected.getFullYear() === currentYear.value
  );
}

function prevMonth() {
  const d = new Date(localDate.value);
  d.setMonth(d.getMonth() - 1);
  localDate.value = d;
}

function nextMonth() {
  const d = new Date(localDate.value);
  d.setMonth(d.getMonth() + 1);
  localDate.value = d;
}
</script>
