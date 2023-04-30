package counter

import (
	"fmt"
	"math/rand"
	"time"
	"os"
)

const (
	ON = iota
	OFF
)


type Counter struct {
	status chan int
	handle func(int)
}

// LD: CHANGE CODE:
// LD: mockMode can be set to 4 modes to determine the kind of mocked counter data
func (counter *Counter) runDevice(interrupt chan struct{}) {
	data := 0
	var sleepTime time.Duration
	var mockMode = os.Getenv("MOCK_MODE")
	fmt.Println("Mock Mode: " + mockMode)

	switch mockMode {
	case "regularCountUp":
		sleepTime = 1 * time.Second
	case "fastCountUp":
		sleepTime = 400 * time.Millisecond
	case "randomCount":
		sleepTime = time.Duration(int64(1.5 * float64(time.Second)))
	case "slowCountUp":
		sleepTime = 2 * time.Second
	default:
		panic(fmt.Sprintf("Unknown Mock Mode: %s", mockMode))
	}

	for {
		select {
		case <-interrupt:
			counter.handle(0)
			return
		default:
			if mockMode == "randomCount" {
				data = rand.Intn(151) + 50
				counter.handle(data)
			} else {
				data++
				counter.handle(data)
			}
			
			fmt.Println("Pseudo sensor counted value:", data)
			
			time.Sleep(sleepTime)
		}
	}
}

func (counter *Counter) initDevice() {
	interrupt := make(chan struct{})

	for {
		select {
		case status := <-counter.status:
			if status == ON {
				go counter.runDevice(interrupt)
			}
			if status == OFF {
				interrupt <- struct{}{}
			}
		}
	}
}

func (counter *Counter) TurnOn() {
	counter.status <- ON
}

func (counter *Counter) TurnOff() {
	counter.status <- OFF
}

func NewCounter(h func(int)) *Counter {
	counter := &Counter{
		status: make(chan int),
		handle: h,
	}

	go counter.initDevice()

	return counter
}

func CloseCounter(counter *Counter) {
	close(counter.status)
}