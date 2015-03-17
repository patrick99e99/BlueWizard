#ifndef __TMS5220_H__
#define __TMS5220_H__

/* HACK: if defined, uses impossibly perfect 'straight line' interpolation */
#undef PERFECT_INTERPOLATION_HACK

#define FIFO_SIZE 16

/* clock rate = 80 * output sample rate,     */
/* usually 640000 for 8000 Hz sample rate or */
/* usually 800000 for 10000 Hz sample rate.  */

#ifndef FALSE
    #define FALSE false;
#endif
#ifndef TRUE
    #define TRUE  true;
#endif
#ifndef NULL
    #define NULL  0;
#endif

class tms5220_device
{
public:
	// static configuration helpers

	/* Control lines - once written to will switch interface into
	 * "true" timing behaviour.
	 */

	/* all lines with suffix q are active low! */

    void rsq_w(int state);
    void wsq_w(int state);
    
    int status_r();
    void data_w(int data);

    int readyq_r();
    int intq_r();
    
	double time_to_ready();
    
	void device_start();
    void device_reset();

	void set_frequency(int frequency);

	void process(int *buffer, unsigned int size);
    int next_sample();
	int m_ready_pin;        /* state of the READY pin (output) */
	int m_fifo_count;
    
    void set_use_raw_excitation_filter(bool yes_or_no);

protected:
	void device_config_complete();

    void update_stream();


	void set_variant(int variant);

private:
	void register_for_save_states();
	void data_write(int data);
	void update_status_and_ints();
	int extract_bits(int count);
	int status_read();
	int ready_read();
	int cycles_to_ready();
	int int_read();

	int lattice_filter();
	void process_command(unsigned char cmd);
	void parse_frame();
	void set_interrupt_state(int state);
	void update_ready_state();
    void reset();
    void logerror(const char *string, ...) {};

	// internal state

	/* coefficient tables */
	int m_variant;                /* Variant of the 5xxx - see tms5110r.h */

	/* coefficient tables */
	const struct tms5100_coeffs *m_coeff;

	/* these contain data that describes the 128-bit data FIFO */
	int m_fifo[FIFO_SIZE];
	int m_fifo_head;
	int m_fifo_tail;
	int m_fifo_bits_taken;


	/* these contain global status bits */
	int m_speaking_now;     /* True only if actual speech is being generated right now. Is set when a speak vsm command happens OR when speak external happens and buffer low becomes nontrue; Is cleared when speech halts after the last stop frame or the last frame after talk status is otherwise cleared.*/
	int m_speak_external;   /* If 1, DDIS is 1, i.e. Speak External command in progress, writes go to FIFO. */
	int m_talk_status;      /* If 1, TS status bit is 1, i.e. speak or speak external is in progress and we have not encountered a stop frame yet; talk_status differs from speaking_now in that speaking_now is set as soon as a speak or speak external command is started; talk_status does NOT go active until after 8 bytes are written to the fifo on a speak external command, otherwise the two are the same. TS is cleared by 3 things: 1. when a STOP command has just been processed as a new frame in the speech stream; 2. if the fifo runs out in speak external mode; 3. on power-up/during a reset command; When it gets cleared, speak_external is also cleared, an interrupt is generated, and speaking_now will be cleared when the next frame starts. */
	int m_buffer_low;       /* If 1, FIFO has less than 8 bytes in it */
	int m_buffer_empty;     /* If 1, FIFO is empty */
	int m_irq_pin;          /* state of the IRQ pin (output) */

	/* these contain data describing the current and previous voice frames */
#define OLD_FRAME_SILENCE_FLAG m_OLDE // 1 if E=0, 0 otherwise.
#define OLD_FRAME_UNVOICED_FLAG m_OLDP // 1 if P=0 (unvoiced), 0 if voiced
	int m_OLDE;
	int m_OLDP;

#define NEW_FRAME_STOP_FLAG (m_new_frame_energy_idx == 0xF) // 1 if this is a stop (Energy = 0xF) frame
#define NEW_FRAME_SILENCE_FLAG (m_new_frame_energy_idx == 0) // ditto as above
#define NEW_FRAME_UNVOICED_FLAG (m_new_frame_pitch_idx == 0) // ditto as above
	int m_new_frame_energy_idx;
	int m_new_frame_pitch_idx;
	int m_new_frame_k_idx[10];


	/* these are all used to contain the current state of the sound generation */
#ifndef PERFECT_INTERPOLATION_HACK
	int m_current_energy;
	int m_current_pitch;
	int m_current_k[10];

	int m_target_energy;
	int m_target_pitch;
	int m_target_k[10];
#else
	int m_old_frame_energy_idx;
	int m_old_frame_pitch_idx;
	int m_old_frame_k_idx[10];

	int m_current_energy;
	int m_current_pitch;
	int m_current_k[10];

	int m_target_energy;
	int m_target_pitch;
	int m_target_k[10];
#endif

	int m_previous_energy; /* needed for lattice filter to match patent */

	int m_subcycle;         /* contains the current subcycle for a given PC: 0 is A' (only used on SPKSLOW mode on 51xx), 1 is A, 2 is B */
	int m_subc_reload;      /* contains 1 for normal speech, 0 when SPKSLOW is active */
	int m_PC;               /* current parameter counter (what param is being interpolated), ranges from 0 to 12 */
	/* TODO/NOTE: the current interpolation period, counts 1,2,3,4,5,6,7,0 for divide by 8,8,8,4,4,2,2,1 */
	int m_IP;               /* the current interpolation period */
	int m_inhibit;          /* If 1, interpolation is inhibited until the DIV1 period */
	int m_c_variant_rate;    /* only relevant for tms5220C's multi frame rate feature; is the actual 4 bit value written on a 0x2* or 0x0* command */
	int m_pitch_count;     /* pitch counter; provides chirp rom address */

	int m_u[11];
	int m_x[10];

	int m_RNG;             /* the random noise generator configuration is: 1 + x + x^3 + x^4 + x^13 */
	int m_excitation_data;

	/* R Nabet : These have been added to emulate speech Roms */
	int m_schedule_dummy_read;          /* set after each load address, so that next read operation is preceded by a dummy read */
	int m_data_register;                /* data register, used by read command */
	int m_RDB_flag;                 /* whether we should read data register or status register */

	/* io_ready: page 3 of the datasheet specifies that READY will be asserted until
	 * data is available or processed by the system.
	 */
	int m_io_ready;

	/* flag for "true" timing involving rs/ws */
	int m_true_timing;

	/* rsws - state, rs bit 1, ws bit 0 */
	int m_rs_ws;
	int m_read_latch;
	int m_write_latch;

	/* The TMS52xx has two different ways of providing output data: the
	   analog speaker pin (which was usually used) and the Digital I/O pin.
	   The internal DAC used to feed the analog pin is only 8 bits, and has the
	   funny clipping/clamping logic, while the digital pin gives full 10 bit
	   resolution of the output data.
	   TODO: add a way to set/reset this other than the FORCE_DIGITAL define
	 */
	int m_digital_select;

	int m_clock;
    
    bool use_raw_excitation_filter;
};

#endif
