const url = "https://atcoder-calendar.tkt989.info/calendar"

const abc = document.querySelector("#abc")
const agc = document.querySelector("#agc")
const unknown = document.querySelector("#unknown")

const all = document.querySelector("#all")
const rateNum = document.querySelector("#rate-num")
const rate = document.querySelector("#rate")

const copy = document.querySelector("#copy")
const text = document.querySelector("#text")

abc.checked = true
agc.checked = true
unknown.checked = true;
all.checked = true;

function updateUrl() {
  const type = [abc, agc, unknown].every(input => input.checked) ? "":
    [abc, agc, unknown]
      .filter(input => input.checked)
      .map(input => input.id)
      .join(",")
  const rating = all.checked ? "" : rate.value

  const params = []

  if (type !== "") {
    params.push("type=" + type)
  }
  if (rating !== "") {
    params.push("rating=" + rating)
  }

  if (params.length !== 0) {
    text.value = url + "?" + params.join("&")
    return
  }
  text.value = url
}

[abc, agc, unknown, all, rateNum, rate].forEach(input => {
  input.addEventListener("input", updateUrl)
})

copy.addEventListener("click", () => {
  text.select()
  document.execCommand("copy")
})

text.value = url